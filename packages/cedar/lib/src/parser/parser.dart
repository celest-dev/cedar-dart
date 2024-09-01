import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/extensions.dart';
import 'package:cedar/src/parser/tokenizer.dart';

typedef _BinaryExprBuilder = CedarExpr Function({
  required CedarExpr left,
  required CedarExpr right,
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

  CedarPolicy readPolicy() {
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
    return CedarPolicy(
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

  CedarEffect readEffect() {
    final effect = advance().text;
    if (effect == 'permit') {
      return CedarEffect.permit;
    } else if (effect == 'forbid') {
      return CedarEffect.forbid;
    }
    error('Unexpected effect: "$effect". Expected permit or forbid');
  }

  CedarPrincipalScope readPrincipalScope() {
    expect('principal');
    switch (peek()?.text) {
      case '==':
        advance();
        final entity = readComponent();
        return CedarPrincipalEquals(entity);
      case 'is':
        advance();
        final path = readPath();
        if (peek()?.text == 'in') {
          advance();
          final set = readComponent();
          return CedarPrincipalIsIn(path, set);
        }
        return CedarPrincipalIs(path);
      case 'in':
        advance();
        final set = readComponent();
        return CedarPrincipalIn(set);
      default:
        return const CedarPrincipalAll();
    }
  }

  CedarComponent readComponent() {
    switch (advance()) {
      case Token(type: TokenType.ident, text: final type):
        return _prereadEntityId(type);
      case Token(type: TokenType.slot, text: final slotId):
        return CedarSlotId.fromJson(slotId);
      default:
        error('Expected entity identifier or slot');
    }
  }

  CedarEntityId readEntity() {
    final ident = advance();
    return _prereadEntityId(ident.text);
  }

  CedarEntityId _prereadEntityId(String type) {
    for (;;) {
      expect('::');
      switch (advance()) {
        case Token(type: TokenType.ident, text: final part):
          type = '$type::$part';
        case Token(type: TokenType.string, stringValue: final id):
          return CedarEntityId(type, id);
        default:
          error('Unexpected token');
      }
    }
  }

  List<CedarEntityId> readEntityList() {
    final entities = <CedarEntityId>[];
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

  CedarExpr _readEntityOrExtensionCall(String prefix) {
    for (;;) {
      switch (advance().text) {
        case '::':
          switch (advance()) {
            case Token(type: TokenType.ident, :final text):
              prefix = '$prefix::$text';
            case Token(type: TokenType.string, stringValue: final id):
              return CedarExpr.value(
                CedarValue.entity(entityId: CedarEntityId(prefix, id)),
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
          return CedarExpr.funcCall(fn: prefix, args: args);
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

  CedarActionScope readActionScope() {
    expect('action');
    switch (peek()?.text) {
      case '==':
        advance();
        final action = readEntity();
        return CedarActionEquals(action);
      case 'in':
        advance();
        if (peek()?.text == '[') {
          final entities = readEntityList();
          return CedarActionInSet(entities);
        }
        final set = readEntity();
        return CedarActionIn(set);
      default:
        return const CedarActionAll();
    }
  }

  CedarResourceScope readResourceScope() {
    expect('resource');
    switch (peek()?.text) {
      case '==':
        advance();
        final entity = readComponent();
        return CedarResourceEquals(entity);
      case 'is':
        advance();
        final path = readPath();
        if (peek()?.text == 'in') {
          advance();
          final set = readComponent();
          return CedarResourceIsIn(path, set);
        }
        return CedarResourceIs(path);
      case 'in':
        advance();
        final set = readComponent();
        return CedarResourceIn(set);
      default:
        return const CedarResourceAll();
    }
  }

  List<CedarCondition> readConditions() {
    final conditions = <CedarCondition>[];
    for (;;) {
      switch (peek()?.text) {
        case 'when':
          advance();
          final body = readCondition();
          conditions.add(CedarCondition(
            kind: CedarConditionKind.when,
            body: body,
          ));
        case 'unless':
          advance();
          final body = readCondition();
          conditions.add(CedarCondition(
            kind: CedarConditionKind.unless,
            body: body,
          ));
        default:
          return conditions;
      }
    }
  }

  CedarExpr readCondition() {
    expect('{');
    final expr = readExpression();
    expect('}');
    return expr;
  }

  CedarExpr readExpression() {
    if (peek()?.text == 'if') {
      advance();

      final cond = readExpression();
      expect('then');
      final then = readExpression();
      expect('else');
      final otherwise = readExpression();

      return CedarExpr.ifThenElse(cond: cond, then: then, else$: otherwise);
    }

    return _readOr();
  }

  CedarExpr _readOr() {
    var lhs = _readAnd();
    while (peek()?.text == '||') {
      advance();
      final rhs = _readAnd();
      lhs = CedarExpr.or(left: lhs, right: rhs);
    }
    return lhs;
  }

  CedarExpr _readAnd() {
    var lhs = _readRelation();

    while (peek()?.text == '&&') {
      advance();
      final rhs = _readRelation();
      lhs = CedarExpr.and(left: lhs, right: rhs);
    }

    return lhs;
  }

  CedarExpr _readHas(CedarExpr lhs) {
    switch (advance()) {
      case Token(type: TokenType.ident, text: final attr):
        return lhs.has(attr);
      case Token(type: TokenType.string, stringValue: final attr):
        return lhs.has(attr);
      default:
        error('Expected attribute name');
    }
  }

  CedarExpr _readLike(CedarExpr lhs) {
    var patternRaw = expectString().text;
    if (patternRaw.startsWith('"')) {
      patternRaw = patternRaw.substring(1, patternRaw.length - 1);
    }
    final pattern = CedarPattern.parse(patternRaw);
    return lhs.like(pattern);
  }

  CedarExpr _readIs(CedarExpr lhs) {
    final entityType = readPath();
    if (peek()?.text == 'in') {
      advance();
      final inEntity = _readAdd();
      return lhs.isIn(entityType, inEntity);
    }
    return lhs.is_(entityType);
  }

  CedarExpr _readRelation() {
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
      '==' => CedarExpr.equals,
      '!=' => CedarExpr.notEquals,
      '<' => CedarExpr.lessThan,
      '<=' => CedarExpr.lessThanOrEquals,
      '>' => CedarExpr.greaterThan,
      '>=' => CedarExpr.greaterThanOrEquals,
      'in' => CedarExpr.in_,
      _ => null,
    };
    if (builder == null) {
      return lhs;
    }

    advance();
    final rhs = _readAdd();
    return builder(left: lhs, right: rhs);
  }

  CedarExpr _readAdd() {
    var lhs = _readMult();
    for (;;) {
      final _BinaryExprBuilder? builder = switch (peek()?.text) {
        '+' => CedarExpr.plus,
        '-' => CedarExpr.minus,
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

  CedarExpr _readMult() {
    var lhs = _readUnary();
    while (peek()?.text == '*') {
      advance();
      final rhs = _readUnary();
      lhs = CedarExpr.times(left: lhs, right: rhs);
    }
    return lhs;
  }

  CedarExpr _readUnary() {
    final ops = <bool>[];
    for (;;) {
      final operation = peek();
      if (operation?.text != '-' && operation?.text != '!') {
        break;
      }
      advance();
      ops.add(operation?.text == '-');
    }

    CedarExpr result;

    // Special case for max negative long
    final token = peek();
    if (ops.isNotEmpty && ops.last && token?.type == TokenType.int) {
      advance();
      final value = int.parse('-${token!.text}');
      result = CedarExpr.value(CedarValue.long(value));
      ops.removeLast();
    } else {
      result = _readMember();
    }

    for (var i = ops.length - 1; i >= 0; i--) {
      result = ops[i] ? CedarExpr.negate(result) : CedarExpr.not(result);
    }
    return result;
  }

  CedarExpr _readMember() {
    var result = _readPrimary();
    for (;;) {
      if (_readAccess(result) case final access?) {
        result = access;
      } else {
        return result;
      }
    }
  }

  CedarExpr _readPrimary() {
    switch (advance()) {
      case Token(type: TokenType.int, :final intValue):
        return CedarExpr.value(CedarValue.long(intValue));
      case Token(type: TokenType.string, :final stringValue):
        return CedarExpr.value(CedarValue.string(stringValue));
      case Token(text: 'true'):
        return CedarExpr.value(CedarValue.bool(true));
      case Token(text: 'false'):
        return CedarExpr.value(CedarValue.bool(false));
      case Token(text: 'principal'):
        return CedarExpr.variable(CedarVariable.principal);
      case Token(text: 'action'):
        return CedarExpr.variable(CedarVariable.action);
      case Token(text: 'resource'):
        return CedarExpr.variable(CedarVariable.resource);
      case Token(text: 'context'):
        return CedarExpr.variable(CedarVariable.context);
      case Token(type: TokenType.ident, text: final ident):
        return _readEntityOrExtensionCall(ident);
      case Token(text: '('):
        final expr = readExpression();
        expect(')');
        return expr;
      case Token(text: '['):
        final elements = _expressions(']');
        return CedarExpr.set(elements);
      case Token(text: '{'):
        return CedarExpr.record(_readRecord());
      default:
        error('Invalid primary expression');
    }
  }

  CedarExpr? _readAccess(CedarExpr lhs) {
    switch (peek()?.text) {
      case '.':
        advance();
        final ident = expectIdent().text;
        if (peek()?.text != '(') {
          return CedarExpr.getAttribute(left: lhs, attr: ident);
        }
        advance();
        final methodName = ident;
        final args = _expressions(')');
        final _BinaryExprBuilder builder;
        switch (methodName) {
          case 'contains':
            builder = CedarExpr.contains;
          case 'containsAll':
            builder = CedarExpr.containsAll;
          case 'containsAny':
            builder = CedarExpr.containsAny;
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
            return CedarExpr.funcCall(fn: methodName, args: args);
        }
        if (args.length != 1) {
          error('Expected exactly one argument to $methodName');
        }
        return builder(left: lhs, right: args.first);
      case '[':
        advance();
        final attr = expectString().stringValue;
        expect(']');
        return CedarExpr.getAttribute(left: lhs, attr: attr);
      default:
        return null;
    }
  }

  List<CedarExpr> _expressions(String endOfListMarker) {
    final expressions = <CedarExpr>[];
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

  Map<String, CedarExpr> _readRecord() {
    final pairs = <String, CedarExpr>{};
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

  (String, CedarExpr) _readRecordEntry() {
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
