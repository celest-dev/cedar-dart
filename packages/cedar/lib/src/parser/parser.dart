import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/extensions.dart';
import 'package:cedar/src/parser/tokenizer.dart';
import 'package:fixnum/fixnum.dart';

typedef _BinaryExprBuilder = Expr Function({
  required Expr left,
  required Expr right,
});

final class Parser {
  Parser(this.tokens) : _index = 0;

  var _index = 0;
  final List<Token> tokens;

  Token get _current => tokens[_index];
  bool get isDone => tokens[_index].isEof;

  Token advance() {
    if (isDone) {
      error('No more tokens');
    }
    return tokens[_index++];
  }

  Token? peek() {
    if (isDone) {
      return null;
    }
    return tokens[_index];
  }

  void expect(String token) {
    if (advance().text != token) {
      error('Expected $token');
    }
  }

  Token expectIdent() {
    final token = advance();
    if (!token.isIdent) {
      error('Expected identifier, got $token');
    }
    return token;
  }

  Token expectString() {
    final token = advance();
    if (!token.isString) {
      error('Expected string');
    }
    return token;
  }

  void expectEof() {
    if (!isDone) {
      error('Expected end of file');
    }
  }

  Never error(String message) {
    throw StateError(_current.span.message(message));
  }

  Policy readPolicy() {
    final annotations = readAnnotations();
    final effect = readEffect();
    expect('(');
    final principal = readPrincipalScope();
    expect(',');
    final action = readActionScope();
    expect(',');
    final resource = readResourceScope();
    expect(')');
    final conditions = readConditions();
    expect(';');
    return Policy(
      annotations: annotations,
      effect: effect,
      principal: principal,
      action: action,
      resource: resource,
      conditions: conditions,
    );
  }

  Annotations readAnnotations() {
    final annotations = <String, String>{};
    while (peek()?.text == '@') {
      advance();
      readAnnotation(annotations);
    }
    return Annotations(annotations);
  }

  void readAnnotation(Map<String, String> annotations) {
    final ident = expectIdent();
    final name = ident.text;
    expect('(');
    if (annotations.containsKey(name)) {
      error('Duplicate annotation: @$name');
    }
    final value = expectString();
    expect(')');
    annotations[name] = value.stringValue;
  }

  Effect readEffect() {
    final effect = advance().text;
    if (effect == 'permit') {
      return Effect.permit;
    } else if (effect == 'forbid') {
      return Effect.forbid;
    }
    error('Unexpected effect: "$effect". Expected permit or forbid');
  }

  PrincipalConstraint readPrincipalScope() {
    expect('principal');
    switch (peek()?.text) {
      case '==':
        advance();
        final entity = readComponent();
        return PrincipalEquals(entity);
      case 'is':
        advance();
        final path = readPath();
        if (peek()?.text == 'in') {
          advance();
          final set = readComponent();
          return PrincipalIsIn(path, set);
        }
        return PrincipalIs(path);
      case 'in':
        advance();
        final set = readComponent();
        return PrincipalIn(set);
      default:
        return const PrincipalAll();
    }
  }

  Component readComponent() {
    switch (advance()) {
      case Token(type: TokenType.ident, text: final type):
        return EntityValue(uid: _prereadEntityId(type));
      case Token(type: TokenType.slot, text: final slotId):
        return SlotId.fromJson(slotId);
      default:
        error('Expected entity identifier or slot');
    }
  }

  EntityUid readEntity() {
    final ident = advance();
    return _prereadEntityId(ident.text);
  }

  EntityUid _prereadEntityId(String type) {
    for (;;) {
      expect('::');
      switch (advance()) {
        case Token(type: TokenType.ident, text: final part):
          type = '$type::$part';
        case Token(type: TokenType.string, stringValue: final id):
          return EntityUid.of(type, id);
        default:
          error('Unexpected token');
      }
    }
  }

  List<EntityUid> readEntityList() {
    final entities = <EntityUid>[];
    expect('[');
    if (peek()?.text == ']') {
      advance();
      return entities;
    }
    for (;;) {
      final entity = readEntity();
      entities.add(entity);
      if (peek()?.text == ']') {
        advance();
        return entities;
      }
      expect(',');
    }
  }

  Expr _readEntityOrExtensionCall(String prefix) {
    for (;;) {
      switch (advance().text) {
        case '::':
          switch (advance()) {
            case Token(type: TokenType.ident, :final text):
              prefix = '$prefix::$text';
            case Token(type: TokenType.string, stringValue: final id):
              return Expr.value(
                Value.entity(uid: EntityUid.of(prefix, id)),
              );
            default:
              error('Unexpected token');
          }
        case '(':
          final extension = extensions[prefix];
          if (extension == null) {
            error('`$prefix` is not a known extension method');
          }
          if (extension.isMethod) {
            error('`$prefix` is a method, not a function');
          }
          final args = _expressions(')');
          return Expr.funcCall(fn: prefix, args: args);
        default:
          error('Unexpected token');
      }
    }
  }

  String readPath() {
    final path = StringBuffer();
    path.write(expectIdent().text);
    for (;;) {
      if (peek()?.text != '::') {
        return path.toString();
      }
      advance();
      final part = expectIdent().text;
      path.write('::$part');
    }
  }

  ActionConstraint readActionScope() {
    expect('action');
    switch (peek()?.text) {
      case '==':
        advance();
        final action = readEntity();
        return ActionEquals(action);
      case 'in':
        advance();
        if (peek()?.text == '[') {
          final entities = readEntityList();
          return ActionInSet(entities);
        }
        final set = readEntity();
        return ActionIn(set);
      default:
        return const ActionAll();
    }
  }

  ResourceConstraint readResourceScope() {
    expect('resource');
    switch (peek()?.text) {
      case '==':
        advance();
        final entity = readComponent();
        return ResourceEquals(entity);
      case 'is':
        advance();
        final path = readPath();
        if (peek()?.text == 'in') {
          advance();
          final set = readComponent();
          return ResourceIsIn(path, set);
        }
        return ResourceIs(path);
      case 'in':
        advance();
        final set = readComponent();
        return ResourceIn(set);
      default:
        return const ResourceAll();
    }
  }

  List<Condition> readConditions() {
    final conditions = <Condition>[];
    for (;;) {
      switch (peek()?.text) {
        case 'when':
          advance();
          final body = readCondition();
          conditions.add(Condition(
            kind: ConditionKind.when,
            body: body,
          ));
        case 'unless':
          advance();
          final body = readCondition();
          conditions.add(Condition(
            kind: ConditionKind.unless,
            body: body,
          ));
        default:
          return conditions;
      }
    }
  }

  Expr readCondition() {
    expect('{');
    final expr = readExpression();
    expect('}');
    return expr;
  }

  Expr readExpression() {
    if (peek()?.text == 'if') {
      advance();

      final cond = readExpression();
      expect('then');
      final then = readExpression();
      expect('else');
      final otherwise = readExpression();

      return Expr.ifThenElse(cond: cond, then: then, else$: otherwise);
    }

    return _readOr();
  }

  Expr _readOr() {
    var lhs = _readAnd();
    while (peek()?.text == '||') {
      advance();
      final rhs = _readAnd();
      lhs = Expr.or(left: lhs, right: rhs);
    }
    return lhs;
  }

  Expr _readAnd() {
    var lhs = _readRelation();

    while (peek()?.text == '&&') {
      advance();
      final rhs = _readRelation();
      lhs = Expr.and(left: lhs, right: rhs);
    }

    return lhs;
  }

  Expr _readHas(Expr lhs) {
    switch (advance()) {
      case Token(type: TokenType.ident, text: final attr):
        return lhs.has(attr);
      case Token(type: TokenType.string, stringValue: final attr):
        return lhs.has(attr);
      default:
        error('Expected attribute name');
    }
  }

  Expr _readLike(Expr lhs) {
    var patternRaw = expectString().text;
    if (patternRaw.startsWith('"')) {
      patternRaw = patternRaw.substring(1, patternRaw.length - 1);
    }
    final pattern = CedarPattern.parse(patternRaw);
    return lhs.like(pattern);
  }

  Expr _readIs(Expr lhs) {
    final entityType = readPath();
    if (peek()?.text == 'in') {
      advance();
      final inEntity = _readAdd();
      return lhs.isIn(entityType, inEntity);
    }
    return lhs.is_(entityType);
  }

  Expr _readRelation() {
    final lhs = _readAdd();

    switch (peek()?.text) {
      case 'has':
        advance();
        return _readHas(lhs);
      case 'like':
        advance();
        return _readLike(lhs);
      case 'is':
        advance();
        return _readIs(lhs);
    }

    // RELOP
    final _BinaryExprBuilder? builder = switch (peek()?.text) {
      '==' => Expr.equals,
      '!=' => Expr.notEquals,
      '<' => Expr.lessThan,
      '<=' => Expr.lessThanOrEquals,
      '>' => Expr.greaterThan,
      '>=' => Expr.greaterThanOrEquals,
      'in' => Expr.in_,
      _ => null,
    };
    if (builder == null) {
      return lhs;
    }

    advance();
    final rhs = _readAdd();
    return builder(left: lhs, right: rhs);
  }

  Expr _readAdd() {
    var lhs = _readMult();
    for (;;) {
      final _BinaryExprBuilder? builder = switch (peek()?.text) {
        '+' => Expr.plus,
        '-' => Expr.minus,
        _ => null,
      };
      if (builder == null) {
        return lhs;
      }
      advance();
      final rhs = _readMult();
      lhs = builder(left: lhs, right: rhs);
    }
  }

  Expr _readMult() {
    var lhs = _readUnary();
    while (peek()?.text == '*') {
      advance();
      final rhs = _readUnary();
      lhs = Expr.times(left: lhs, right: rhs);
    }
    return lhs;
  }

  Expr _readUnary() {
    final ops = <bool>[];
    for (;;) {
      final operation = peek();
      if (operation?.text != '-' && operation?.text != '!') {
        break;
      }
      advance();
      ops.add(operation?.text == '-');
    }

    Expr result;

    // Special case for max negative long
    final token = peek();
    if (ops.isNotEmpty && ops.last && token?.type == TokenType.int) {
      advance();
      final value = -Int64.parseInt(token!.text);
      result = Expr.value(Value.long(value));
      ops.removeLast();
    } else {
      result = _readMember();
    }

    for (var i = ops.length - 1; i >= 0; i--) {
      result = ops[i] ? Expr.negate(result) : Expr.not(result);
    }
    return result;
  }

  Expr _readMember() {
    var result = _readPrimary();
    for (;;) {
      if (_readAccess(result) case final access?) {
        result = access;
      } else {
        return result;
      }
    }
  }

  Expr _readPrimary() {
    switch (advance()) {
      case Token(type: TokenType.int, :final intValue):
        return Expr.value(Value.long(intValue));
      case Token(type: TokenType.string, :final stringValue):
        return Expr.value(Value.string(stringValue));
      case Token(text: 'true'):
        return Expr.value(Value.bool(true));
      case Token(text: 'false'):
        return Expr.value(Value.bool(false));
      case Token(text: 'principal'):
        return Expr.variable(CedarVariable.principal);
      case Token(text: 'action'):
        return Expr.variable(CedarVariable.action);
      case Token(text: 'resource'):
        return Expr.variable(CedarVariable.resource);
      case Token(text: 'context'):
        return Expr.variable(CedarVariable.context);
      case Token(type: TokenType.ident, text: final ident):
        return _readEntityOrExtensionCall(ident);
      case Token(text: '('):
        final expr = readExpression();
        expect(')');
        return expr;
      case Token(text: '['):
        final elements = _expressions(']');
        return Expr.set(elements);
      case Token(text: '{'):
        return Expr.record(_readRecord());
      default:
        error('Invalid primary expression');
    }
  }

  Expr? _readAccess(Expr lhs) {
    switch (peek()?.text) {
      case '.':
        advance();
        final ident = expectIdent().text;
        if (peek()?.text != '(') {
          return Expr.getAttribute(left: lhs, attr: ident);
        }
        advance();
        final methodName = ident;
        final args = _expressions(')');
        final _BinaryExprBuilder builder;
        switch (methodName) {
          case 'contains':
            builder = Expr.contains;
          case 'containsAll':
            builder = Expr.containsAll;
          case 'containsAny':
            builder = Expr.containsAny;
          default:
            // Although the Cedar grammar says that any name can be provided here, the reference implementation
            // actually checks at parse time whether the name corresponds to a known extension method.
            final extension = extensions[methodName];
            if (extension == null) {
              error('`$methodName` is not a known extension method');
            }
            if (!extension.isMethod) {
              error('`$methodName` is a function, not a method');
            }
            return Expr.funcCall(fn: methodName, args: args);
        }
        if (args.length != 1) {
          error('Expected exactly one argument to $methodName');
        }
        return builder(left: lhs, right: args.first);
      case '[':
        advance();
        final attr = expectString().stringValue;
        expect(']');
        return Expr.getAttribute(left: lhs, attr: attr);
      default:
        return null;
    }
  }

  List<Expr> _expressions(String endOfListMarker) {
    final expressions = <Expr>[];
    while (peek()?.text != endOfListMarker) {
      expressions.add(readExpression());
      if (peek()?.text == endOfListMarker) {
        break;
      }
      expect(',');
    }
    advance();
    return expressions;
  }

  Map<String, Expr> _readRecord() {
    final pairs = <String, Expr>{};
    for (;;) {
      if (peek()?.text == '}') {
        advance();
        return pairs;
      }
      final (key, value) = _readRecordEntry();
      if (pairs.containsKey(key)) {
        error('Duplicate record entry: $key');
      }
      pairs[key] = value;
    }
  }

  (String, Expr) _readRecordEntry() {
    final key = switch (advance()) {
      Token(type: TokenType.ident, text: final key) => key,
      Token(type: TokenType.string, stringValue: final key) => key,
      _ => error('Unexpected token'),
    };
    expect(':');
    final value = readExpression();
    return (key, value);
  }
}
