import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/extensions.dart';
import 'package:fixnum/fixnum.dart';

extension ExpectCedarValue on Value {
  BoolValue expectBool() {
    if (this case final BoolValue bool) {
      return bool;
    }
    throw TypeException('Expected a boolean, got $runtimeType');
  }

  StringValue expectString() {
    if (this case final StringValue string) {
      return string;
    }
    throw TypeException('Expected a string, got $runtimeType');
  }

  LongValue expectLong() {
    if (this case final LongValue long) {
      return long;
    }
    throw TypeException('Expected a long, got $runtimeType');
  }

  SetValue expectSet() {
    if (this case final SetValue set) {
      return set;
    }
    throw TypeException('Expected a set, got $runtimeType');
  }

  RecordValue expectRecord() {
    if (this case final RecordValue record) {
      return record;
    }
    throw TypeException('Expected a record, got $runtimeType');
  }

  EntityUid expectEntityId() {
    if (this case EntityValue(uid: final entityId)) {
      return entityId;
    }
    throw TypeException('Expected an entity ID, got $runtimeType');
  }

  DecimalValue expectDecimal() {
    if (this case final DecimalValue decimal) {
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

  final Map<EntityUid, Entity> entities;
  final EntityUid principal;
  final EntityUid action;
  final EntityUid resource;
  final RecordValue context;
}

final class Evalutator implements ExprVisitor<Value> {
  Evalutator(this.context);

  final EvaluationContext context;

  static Int64 _checkedAddI64(Int64 lhs, Int64 rhs) {
    final res = lhs + rhs;
    if ((res > lhs) != (rhs > 0)) {
      throw OverflowException(
        'Overflow while attempting to add `$lhs` with `$rhs`',
      );
    }
    return res;
  }

  static Int64 _checkedSubI64(Int64 lhs, Int64 rhs) {
    final res = lhs - rhs;
    if ((res > lhs) != (rhs < 0)) {
      throw OverflowException(
        'Overflow while attempting to subtract `$lhs` with `$rhs`',
      );
    }
    return res;
  }

  static Int64 _checkedMulI64(Int64 lhs, Int64 rhs) {
    if (lhs == 0 || rhs == 0) {
      return Int64.ZERO;
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

  static Int64 _checkedNegI64(Int64 a) {
    if (a == Int64.MIN_VALUE) {
      throw OverflowException(
        'Overflow while attempting to negate `$a`',
      );
    }
    return -a;
  }

  @override
  Value visitAnd(ExprAnd and) {
    final lhs = and.left.accept(this).expectBool();
    if (!lhs.value) {
      return lhs;
    }
    final rhs = and.right.accept(this).expectBool();
    return rhs;
  }

  @override
  Value visitContains(ExprContains contains) {
    final lhs = contains.left.accept(this).expectSet();
    final rhs = contains.right.accept(this);
    return Value.bool(lhs.elements.contains(rhs));
  }

  @override
  Value visitContainsAll(ExprContainsAll containsAll) {
    final lhs = containsAll.left.accept(this).expectSet();
    final rhs = containsAll.right.accept(this).expectSet();
    return Value.bool(rhs.elements.every(lhs.elements.contains));
  }

  @override
  Value visitContainsAny(ExprContainsAny containsAny) {
    final lhs = containsAny.left.accept(this).expectSet();
    final rhs = containsAny.right.accept(this).expectSet();
    return Value.bool(rhs.elements.any(lhs.elements.contains));
  }

  @override
  Value visitEquals(ExprEquals equals) {
    final lhs = equals.left.accept(this);
    final rhs = equals.right.accept(this);
    return Value.bool(lhs == rhs);
  }

  @override
  Value visitExtensionCall(ExprExtensionCall extensionCall) {
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
  Value visitGetAttribute(ExprGetAttribute getAttribute) {
    final value = getAttribute.left.accept(this);
    final Map<String, Value> attrs;
    final String type;
    switch (value) {
      case EntityValue(uid: final entityId):
        type = '`$entityId`';
        if (entityId == const EntityUid.unknown()) {
          throw const UnspecifiedEntityException();
        }
        final entity = context.entities[entityId];
        if (entity == null) {
          throw EntityNotFoundException(entityId);
        }
        attrs = entity.attributes;
      case RecordValue(:final attributes):
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
  Value visitGreaterThan(ExprGreaterThan greaterThan) {
    final lhs = greaterThan.left.accept(this).expectLong();
    final rhs = greaterThan.right.accept(this).expectLong();
    return Value.bool(lhs.value > rhs.value);
  }

  @override
  Value visitGreaterThanOrEquals(ExprGreaterThanOrEquals greaterThanOrEquals) {
    final lhs = greaterThanOrEquals.left.accept(this).expectLong();
    final rhs = greaterThanOrEquals.right.accept(this).expectLong();
    return Value.bool(lhs.value >= rhs.value);
  }

  @override
  Value visitHasAttribute(ExprHasAttribute hasAttribute) {
    final value = hasAttribute.left.accept(this);
    final Map<String, Value> attrs;
    switch (value) {
      case EntityValue(uid: final entityId):
        final entity = context.entities[entityId];
        if (entity == null) {
          return Value.bool(false);
        }
        attrs = entity.attributes;
      case RecordValue(:final attributes):
        attrs = attributes;
      default:
        throw TypeException('Expected entity or record, got $value');
    }
    return Value.bool(attrs.containsKey(hasAttribute.attr));
  }

  @override
  Value visitIfThenElse(ExprIfThenElse ifThenElse) {
    final cond = ifThenElse.cond.accept(this).expectBool();
    if (cond.value) {
      return ifThenElse.then.accept(this);
    }
    return ifThenElse.else$.accept(this);
  }

  @override
  Value visitIn(ExprIn in_) {
    final lhs = in_.left.accept(this).expectEntityId();
    final rhs = in_.right.accept(this);
    final query = <EntityUid>{};

    bool entityIn(EntityUid entity) {
      final checked = <EntityUid>{};
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
      case EntityValue(uid: final entityId):
        query.add(entityId);
      case SetValue(elements: final entities):
        query.addAll(entities.map((e) => e.expectEntityId()));
      default:
        throw TypeException('Expected entity or set, got $rhs');
    }

    return Value.bool(entityIn(lhs));
  }

  @override
  Value visitIs(ExprIs is_) {
    if (is_.inExpr case final inExpr?) {
      final lhs = Expr.is_(left: is_.left, entityType: is_.entityType);
      final rhs = Expr.in_(left: is_.left, right: inExpr);
      final expr = Expr.and(left: lhs, right: rhs);
      return expr.accept(this);
    }
    final lhs = is_.left.accept(this).expectEntityId();
    return Value.bool(lhs.type == is_.entityType);
  }

  @override
  Value visitLessThan(ExprLessThan lessThan) {
    final lhs = lessThan.left.accept(this).expectLong();
    final rhs = lessThan.right.accept(this).expectLong();
    return Value.bool(lhs.value < rhs.value);
  }

  @override
  Value visitLessThanOrEquals(ExprLessThanOrEquals lessThanOrEquals) {
    final lhs = lessThanOrEquals.left.accept(this).expectLong();
    final rhs = lessThanOrEquals.right.accept(this).expectLong();
    return Value.bool(lhs.value <= rhs.value);
  }

  @override
  Value visitLike(ExprLike like) {
    final value = like.left.accept(this).expectString();
    return Value.bool(like.pattern.match(value.value));
  }

  @override
  Value visitSubt(ExprSubt subt) {
    final lhs = subt.left.accept(this).expectLong();
    final rhs = subt.right.accept(this).expectLong();
    return Value.long(_checkedSubI64(lhs.value, rhs.value));
  }

  @override
  Value visitNegate(ExprNegate negate) {
    final arg = negate.arg.accept(this).expectLong();
    return Value.long(_checkedNegI64(arg.value));
  }

  @override
  Value visitNot(ExprNot not) {
    final inner = not.arg.accept(this).expectBool();
    return ~inner;
  }

  @override
  Value visitNotEquals(ExprNotEquals notEquals) {
    final lhs = notEquals.left.accept(this);
    final rhs = notEquals.right.accept(this);
    return Value.bool(lhs != rhs);
  }

  @override
  Value visitOr(ExprOr or) {
    final lhs = or.left.accept(this).expectBool();
    if (lhs.value) {
      return lhs;
    }
    final rhs = or.right.accept(this).expectBool();
    return rhs;
  }

  @override
  Value visitAdd(ExprAdd add) {
    final lhs = add.left.accept(this).expectLong();
    final rhs = add.right.accept(this).expectLong();
    return Value.long(_checkedAddI64(lhs.value, rhs.value));
  }

  @override
  Value visitRecord(ExprRecord record) {
    final elements = <String, Value>{};
    for (final entry in record.attributes.entries) {
      final value = entry.value.accept(this);
      elements[entry.key] = value;
    }
    return Value.record(elements);
  }

  @override
  Value visitSet(ExprSet set) {
    final elements = set.expressions.map((e) => e.accept(this)).toList();
    return Value.set(elements);
  }

  @override
  Value visitSlot(ExprSlot slot) {
    throw UnsupportedError('Templates cannot be evaluated');
  }

  @override
  Value visitMult(ExprMult mult) {
    final lhs = mult.left.accept(this).expectLong();
    final rhs = mult.right.accept(this).expectLong();
    return Value.long(_checkedMulI64(lhs.value, rhs.value));
  }

  @override
  Value visitUnknown(ExprUnknown unknown) {
    throw UnsupportedError('Unknown expression: $unknown');
  }

  @override
  Value visitValue(ExprValue value) {
    return value.value;
  }

  @override
  Value visitVariable(ExprVariable variable) {
    return switch (variable.variable) {
      CedarVariable.principal => EntityValue(uid: context.principal),
      CedarVariable.action => EntityValue(uid: context.action),
      CedarVariable.resource => EntityValue(uid: context.resource),
      CedarVariable.context => context.context,
    };
  }
}
