import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/extensions.dart';

extension ExpectCedarValue on CedarValue {
  CedarBool expectBool() {
    if (this case final CedarBool bool) {
      return bool;
    }
    throw TypeException('Expected a boolean, got $runtimeType');
  }

  CedarString expectString() {
    if (this case final CedarString string) {
      return string;
    }
    throw TypeException('Expected a string, got $runtimeType');
  }

  CedarLong expectLong() {
    if (this case final CedarLong long) {
      return long;
    }
    throw TypeException('Expected a long, got $runtimeType');
  }

  CedarSet expectSet() {
    if (this case final CedarSet set) {
      return set;
    }
    throw TypeException('Expected a set, got $runtimeType');
  }

  CedarRecord expectRecord() {
    if (this case final CedarRecord record) {
      return record;
    }
    throw TypeException('Expected a record, got $runtimeType');
  }

  CedarEntityId expectEntityId() {
    if (this case CedarEntityValue(:final entityId)) {
      return entityId;
    }
    throw TypeException('Expected an entity ID, got $runtimeType');
  }

  CedarDecimal expectDecimal() {
    if (this case final CedarDecimal decimal) {
      return decimal;
    }
    throw TypeException('Expected a decimal, got $runtimeType');
  }
}

final class EvaluationContext {
  EvaluationContext({
    required this.entities,
    required this.principal,
    required this.action,
    required this.resource,
    required this.context,
  });

  final Map<CedarEntityId, CedarEntity> entities;
  final CedarEntityId principal;
  final CedarEntityId action;
  final CedarEntityId resource;
  final CedarRecord context;
}

final class Evalutator implements ExprVisitor<CedarValue> {
  Evalutator(this.context);

  final EvaluationContext context;

  static int _checkedAddI64(int lhs, int rhs) {
    final res = lhs + rhs;
    if ((res > lhs) != (rhs > 0)) {
      throw OverflowException(
        'Overflow while attempting to add `$lhs` with `$rhs`',
      );
    }
    return res;
  }

  static int _checkedSubI64(int lhs, int rhs) {
    final res = lhs - rhs;
    if ((res > lhs) != (rhs < 0)) {
      throw OverflowException(
        'Overflow while attempting to subtract `$lhs` with `$rhs`',
      );
    }
    return res;
  }

  static int _checkedMulI64(int lhs, int rhs) {
    if (lhs == 0 || rhs == 0) {
      return 0;
    }
    final res = lhs * rhs;
    if ((res < 0) != ((lhs < 0) != (rhs < 0))) {
      throw OverflowException(
        'Overflow while attempting to multiply `$lhs` with `$rhs`',
      );
    }
    if (res ~/ lhs != rhs) {
      throw OverflowException(
        'Overflow while attempting to multiply `$lhs` with `$rhs`',
      );
    }
    return res;
  }

  static int _checkedNegI64(int a) {
    if (a == -9223372036854775808) {
      throw OverflowException(
        'Overflow while attempting to negate `$a`',
      );
    }
    return -a;
  }

  @override
  CedarValue visitAnd(CedarExprAnd and) {
    final lhs = and.left.accept(this).expectBool();
    if (!lhs.value) {
      return lhs;
    }
    final rhs = and.right.accept(this).expectBool();
    return rhs;
  }

  @override
  CedarValue visitContains(CedarExprContains contains) {
    final lhs = contains.left.accept(this).expectSet();
    final rhs = contains.right.accept(this);
    return CedarValue.bool(lhs.elements.contains(rhs));
  }

  @override
  CedarValue visitContainsAll(CedarExprContainsAll containsAll) {
    final lhs = containsAll.left.accept(this).expectSet();
    final rhs = containsAll.right.accept(this).expectSet();
    return CedarValue.bool(rhs.elements.every(lhs.elements.contains));
  }

  @override
  CedarValue visitContainsAny(CedarExprContainsAny containsAny) {
    final lhs = containsAny.left.accept(this).expectSet();
    final rhs = containsAny.right.accept(this).expectSet();
    return CedarValue.bool(rhs.elements.any(lhs.elements.contains));
  }

  @override
  CedarValue visitEquals(CedarExprEquals equals) {
    final lhs = equals.left.accept(this);
    final rhs = equals.right.accept(this);
    return CedarValue.bool(lhs == rhs);
  }

  @override
  CedarValue visitFunctionCall(CedarExprFunctionCall extensionCall) {
    if (extensions[extensionCall.fn] case final extension?) {
      if (extension.numArgs != extensionCall.args.length) {
        throw ArityException(
          extensionCall.fn,
          extension.numArgs,
          extensionCall.args.length,
        );
      }
      return extension.evaluate(this, extensionCall.args);
    }
    throw UnknownExtensionException(extensionCall.fn);
  }

  @override
  CedarValue visitGetAttribute(CedarExprGetAttribute getAttribute) {
    final value = getAttribute.left.accept(this);
    final Map<String, CedarValue> attrs;
    final String type;
    switch (value) {
      case CedarEntityValue(:final entityId):
        type = '`$entityId`';
        if (entityId == const CedarEntityId.unknown()) {
          throw const UnspecifiedEntityException();
        }
        final entity = context.entities[entityId];
        if (entity == null) {
          throw EntityNotFoundException(entityId);
        }
        attrs = entity.attributes;
      case CedarRecord(:final attributes):
        type = 'record';
        attrs = attributes;
      default:
        throw TypeException('Expected entity or record, got $value');
    }
    final attr = attrs[getAttribute.attr];
    if (attr == null) {
      throw AttributeAccessException(type, getAttribute.attr);
    }
    return attr;
  }

  @override
  CedarValue visitGreaterThan(CedarExprGreaterThan greaterThan) {
    final lhs = greaterThan.left.accept(this).expectLong();
    final rhs = greaterThan.right.accept(this).expectLong();
    return CedarValue.bool(lhs.value > rhs.value);
  }

  @override
  CedarValue visitGreaterThanOrEquals(
      CedarExprGreaterThanOrEquals greaterThanOrEquals) {
    final lhs = greaterThanOrEquals.left.accept(this).expectLong();
    final rhs = greaterThanOrEquals.right.accept(this).expectLong();
    return CedarValue.bool(lhs.value >= rhs.value);
  }

  @override
  CedarValue visitHasAttribute(CedarExprHasAttribute hasAttribute) {
    final value = hasAttribute.left.accept(this);
    final Map<String, CedarValue> attrs;
    switch (value) {
      case CedarEntityValue(:final entityId):
        final entity = context.entities[entityId];
        if (entity == null) {
          return CedarValue.bool(false);
        }
        attrs = entity.attributes;
      case CedarRecord(:final attributes):
        attrs = attributes;
      default:
        throw TypeException('Expected entity or record, got $value');
    }
    return CedarValue.bool(attrs.containsKey(hasAttribute.attr));
  }

  @override
  CedarValue visitIfThenElse(CedarExprIfThenElse ifThenElse) {
    final cond = ifThenElse.cond.accept(this).expectBool();
    if (cond.value) {
      return ifThenElse.then.accept(this);
    }
    return ifThenElse.else$.accept(this);
  }

  @override
  CedarValue visitIn(CedarExprIn in_) {
    final lhs = in_.left.accept(this).expectEntityId();
    final rhs = in_.right.accept(this);
    final query = <CedarEntityId>{};

    bool entityIn(CedarEntityId entity) {
      final checked = <CedarEntityId>{};
      final toCheck = [entity];
      while (toCheck.isNotEmpty) {
        final candidate = toCheck.removeLast();
        if (checked.contains(candidate)) {
          continue;
        }
        if (query.contains(candidate)) {
          return true;
        }
        final next = context.entities[candidate];
        if (next != null) {
          toCheck.addAll(next.parents);
        }
        checked.add(candidate);
      }
      return false;
    }

    switch (rhs) {
      case CedarEntityValue(:final entityId):
        query.add(entityId);
      case CedarSet(elements: final entities):
        query.addAll(entities.map((e) => e.expectEntityId()));
      default:
        throw TypeException('Expected entity or set, got $rhs');
    }

    return CedarValue.bool(entityIn(lhs));
  }

  @override
  CedarValue visitIs(CedarExprIs is_) {
    if (is_.inExpr case final inExpr?) {
      final lhs = CedarExpr.is_(left: is_.left, entityType: is_.entityType);
      final rhs = CedarExpr.in_(left: is_.left, right: inExpr);
      final expr = CedarExpr.and(left: lhs, right: rhs);
      return expr.accept(this);
    }
    final lhs = is_.left.accept(this).expectEntityId();
    return CedarValue.bool(lhs.type == is_.entityType);
  }

  @override
  CedarValue visitLessThan(CedarExprLessThan lessThan) {
    final lhs = lessThan.left.accept(this).expectLong();
    final rhs = lessThan.right.accept(this).expectLong();
    return CedarValue.bool(lhs.value < rhs.value);
  }

  @override
  CedarValue visitLessThanOrEquals(CedarExprLessThanOrEquals lessThanOrEquals) {
    final lhs = lessThanOrEquals.left.accept(this).expectLong();
    final rhs = lessThanOrEquals.right.accept(this).expectLong();
    return CedarValue.bool(lhs.value <= rhs.value);
  }

  @override
  CedarValue visitLike(CedarExprLike like) {
    final value = like.left.accept(this).expectString();
    return CedarValue.bool(like.pattern.match(value.value));
  }

  @override
  CedarValue visitMinus(CedarExprMinus minus) {
    final lhs = minus.left.accept(this).expectLong();
    final rhs = minus.right.accept(this).expectLong();
    return CedarValue.long(_checkedSubI64(lhs.value, rhs.value));
  }

  @override
  CedarValue visitNegate(CedarExprNegate negate) {
    final arg = negate.arg.accept(this).expectLong();
    return CedarValue.long(_checkedNegI64(arg.value));
  }

  @override
  CedarValue visitNot(CedarExprNot not) {
    final inner = not.arg.accept(this).expectBool();
    return ~inner;
  }

  @override
  CedarValue visitNotEquals(CedarExprNotEquals notEquals) {
    final lhs = notEquals.left.accept(this);
    final rhs = notEquals.right.accept(this);
    return CedarValue.bool(lhs != rhs);
  }

  @override
  CedarValue visitOr(CedarExprOr or) {
    final lhs = or.left.accept(this).expectBool();
    if (lhs.value) {
      return lhs;
    }
    final rhs = or.right.accept(this).expectBool();
    return rhs;
  }

  @override
  CedarValue visitPlus(CedarExprPlus plus) {
    final lhs = plus.left.accept(this).expectLong();
    final rhs = plus.right.accept(this).expectLong();
    return CedarValue.long(_checkedAddI64(lhs.value, rhs.value));
  }

  @override
  CedarValue visitRecord(CedarExprRecord record) {
    final elements = <String, CedarValue>{};
    for (final entry in record.attributes.entries) {
      final value = entry.value.accept(this);
      elements[entry.key] = value;
    }
    return CedarValue.record(elements);
  }

  @override
  CedarValue visitSet(CedarExprSet set) {
    final elements = set.expressions.map((e) => e.accept(this)).toList();
    return CedarValue.set(elements);
  }

  @override
  CedarValue visitSlot(CedarExprSlot slot) {
    throw UnsupportedError('Templates cannot be evaluated');
  }

  @override
  CedarValue visitTimes(CedarExprTimes times) {
    final lhs = times.left.accept(this).expectLong();
    final rhs = times.right.accept(this).expectLong();
    return CedarValue.long(_checkedMulI64(lhs.value, rhs.value));
  }

  @override
  CedarValue visitUnknown(CedarExprUnknown unknown) {
    throw UnsupportedError('Unknown expression: $unknown');
  }

  @override
  CedarValue visitValue(CedarExprValue value) {
    return value.value;
  }

  @override
  CedarValue visitVariable(CedarExprVariable variable) {
    return switch (variable.variable) {
      CedarVariable.principal => CedarEntityValue(entityId: context.principal),
      CedarVariable.action => CedarEntityValue(entityId: context.action),
      CedarVariable.resource => CedarEntityValue(entityId: context.resource),
      CedarVariable.context => context.context,
    };
  }
}
