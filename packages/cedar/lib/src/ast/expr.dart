/// Dart representation of the JSON expression language used in Cedar
/// policies.
///
/// See: https://docs.cedarpolicy.com/policies/json-format.html#JsonExpr-objects
library;

import 'package:cedar/src/ast.dart';
import 'package:cedar/src/model/types/cedar_value.dart';
import 'package:cedar/src/util/pretty_json.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

sealed class CedarOp {
  factory CedarOp.fromJson(String json) => switch (json) {
        'Value' => CedarOpCode.value,
        'Var' => CedarOpCode.variable,
        'Slot' => CedarOpCode.slot,
        'Unknown' => CedarOpCode.unknown,
        '!' => CedarOpCode.not,
        'neg' => CedarOpCode.neg,
        '==' => CedarOpCode.equals,
        '!=' => CedarOpCode.notEquals,
        'in' => CedarOpCode.in$,
        '<' => CedarOpCode.lessThan,
        '<=' => CedarOpCode.lessThanOrEquals,
        '>' => CedarOpCode.greaterThan,
        '>=' => CedarOpCode.greaterThanOrEquals,
        '&&' => CedarOpCode.and,
        '||' => CedarOpCode.or,
        '+' => CedarOpCode.plus,
        '-' => CedarOpCode.minus,
        '*' => CedarOpCode.times,
        'contains' => CedarOpCode.contains,
        'containsAll' => CedarOpCode.containsAll,
        'containsAny' => CedarOpCode.containsAny,
        '.' => CedarOpCode.getAttribute,
        'has' => CedarOpCode.hasAttribute,
        'like' => CedarOpCode.like,
        'is' => CedarOpCode.is$,
        'if-then-else' => CedarOpCode.ifThenElse,
        'Set' => CedarOpCode.set,
        'Record' => CedarOpCode.record,
        _ => CedarOpFunction(json),
      };

  String toJson();
}

final class CedarOpFunction implements CedarOp {
  const CedarOpFunction(this.name);

  final String name;

  @override
  String toJson() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CedarOpFunction && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

enum CedarOpCode implements CedarOp {
  value,
  variable,
  slot,
  unknown,
  not,
  neg,
  equals,
  notEquals,
  in$,
  lessThan,
  lessThanOrEquals,
  greaterThan,
  greaterThanOrEquals,
  and,
  or,
  plus,
  minus,
  times,
  contains,
  containsAll,
  containsAny,
  getAttribute,
  hasAttribute,
  like,
  is$,
  ifThenElse,
  set,
  record;

  @override
  String toJson() => switch (this) {
        value => 'Value',
        variable => 'Var',
        slot => 'Slot',
        unknown => 'Unknown',
        not => '!',
        neg => 'neg',
        equals => '==',
        notEquals => '!=',
        in$ => 'in',
        lessThan => '<',
        lessThanOrEquals => '<=',
        greaterThan => '>',
        greaterThanOrEquals => '>=',
        and => '&&',
        or => '||',
        plus => '+',
        minus => '-',
        times => '*',
        contains => 'contains',
        containsAll => 'containsAll',
        containsAny => 'containsAny',
        getAttribute => '.',
        hasAttribute => 'has',
        like => 'like',
        is$ => 'is',
        ifThenElse => 'if-then-else',
        set => 'Set',
        record => 'Record',
      };
}

sealed class CedarExpr {
  const CedarExpr();

  factory CedarExpr.fromJson(Map<String, Object?> json) {
    if (json.keys.length != 1) {
      throw FormatException('Expected exactly one key in JSON expression');
    }
    final MapEntry(:key, :value) = json.entries.first;
    final op = CedarOp.fromJson(key);
    return switch (op) {
      CedarOpCode.value => CedarExprValue.fromJson(value),
      CedarOpCode.variable => CedarExprVariable.fromJson(value as String),
      CedarOpCode.slot => CedarExprSlot.fromJson(value as String),
      CedarOpCode.unknown =>
        CedarExprUnknown.fromJson(value as Map<String, Object?>),
      CedarOpCode.not => CedarExprNot.fromJson(value as Map<String, Object?>),
      CedarOpCode.neg =>
        CedarExprNegate.fromJson(value as Map<String, Object?>),
      CedarOpCode.equals =>
        CedarExprEquals.fromJson(value as Map<String, Object?>),
      CedarOpCode.notEquals =>
        CedarExprNotEquals.fromJson(value as Map<String, Object?>),
      CedarOpCode.in$ => CedarExprIn.fromJson(value as Map<String, Object?>),
      CedarOpCode.lessThan =>
        CedarExprLessThan.fromJson(value as Map<String, Object?>),
      CedarOpCode.lessThanOrEquals =>
        CedarExprLessThanOrEquals.fromJson(value as Map<String, Object?>),
      CedarOpCode.greaterThan =>
        CedarExprGreaterThan.fromJson(value as Map<String, Object?>),
      CedarOpCode.greaterThanOrEquals =>
        CedarExprGreaterThanOrEquals.fromJson(value as Map<String, Object?>),
      CedarOpCode.and => CedarExprAnd.fromJson(value as Map<String, Object?>),
      CedarOpCode.or => CedarExprOr.fromJson(value as Map<String, Object?>),
      CedarOpCode.plus => CedarExprPlus.fromJson(value as Map<String, Object?>),
      CedarOpCode.minus =>
        CedarExprMinus.fromJson(value as Map<String, Object?>),
      CedarOpCode.times =>
        CedarExprTimes.fromJson(value as Map<String, Object?>),
      CedarOpCode.contains =>
        CedarExprContains.fromJson(value as Map<String, Object?>),
      CedarOpCode.containsAll =>
        CedarExprContainsAll.fromJson(value as Map<String, Object?>),
      CedarOpCode.containsAny =>
        CedarExprContainsAny.fromJson(value as Map<String, Object?>),
      CedarOpCode.getAttribute =>
        CedarExprGetAttribute.fromJson(value as Map<String, Object?>),
      CedarOpCode.hasAttribute =>
        CedarExprHasAttribute.fromJson(value as Map<String, Object?>),
      CedarOpCode.like => CedarExprLike.fromJson(value as Map<String, Object?>),
      CedarOpCode.is$ => CedarExprIs.fromJson(value as Map<String, Object?>),
      CedarOpCode.ifThenElse =>
        CedarExprIfThenElse.fromJson(value as Map<String, Object?>),
      CedarOpCode.set => CedarExprSet.fromJson(value as List<Object?>),
      CedarOpCode.record =>
        CedarExprRecord.fromJson(value as Map<String, Object?>),
      final CedarOpFunction op => CedarExprFunctionCall(
          fn: op.name,
          args: (value as List<Object?>)
              .map((el) => CedarExpr.fromJson(el as Map<String, Object?>))
              .toList(),
        ),
    };
  }

  const factory CedarExpr.value(CedarValue value) = CedarExprValue;

  const factory CedarExpr.variable(CedarVariable variable) = CedarExprVariable;

  const factory CedarExpr.slot(CedarSlotId slotId) = CedarExprSlot;

  const factory CedarExpr.unknown(String name) = CedarExprUnknown;

  const factory CedarExpr.not(CedarExpr arg) = CedarExprNot;

  const factory CedarExpr.negate(CedarExpr arg) = CedarExprNegate;

  const factory CedarExpr.equals({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprEquals;

  const factory CedarExpr.notEquals({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprNotEquals;

  const factory CedarExpr.in_({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprIn;

  const factory CedarExpr.lessThan({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprLessThan;

  const factory CedarExpr.lessThanOrEquals({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprLessThanOrEquals;

  const factory CedarExpr.greaterThan({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprGreaterThan;

  const factory CedarExpr.greaterThanOrEquals({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprGreaterThanOrEquals;

  const factory CedarExpr.and({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprAnd;

  const factory CedarExpr.or({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprOr;

  const factory CedarExpr.plus({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprPlus;

  const factory CedarExpr.minus({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprMinus;

  const factory CedarExpr.times({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprTimes;

  const factory CedarExpr.contains({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprContains;

  const factory CedarExpr.containsAll({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprContainsAll;

  const factory CedarExpr.containsAny({
    required CedarExpr left,
    required CedarExpr right,
  }) = CedarExprContainsAny;

  const factory CedarExpr.getAttribute({
    required CedarExpr left,
    required String attr,
  }) = CedarExprGetAttribute;

  const factory CedarExpr.hasAttribute({
    required CedarExpr left,
    required String attr,
  }) = CedarExprHasAttribute;

  const factory CedarExpr.like({
    required CedarExpr left,
    required CedarPattern pattern,
  }) = CedarExprLike;

  const factory CedarExpr.is_({
    required CedarExpr left,
    required String entityType,
    CedarExpr? inExpr,
  }) = CedarExprIs;

  const factory CedarExpr.ifThenElse({
    required CedarExpr cond,
    required CedarExpr then,
    required CedarExpr else$,
  }) = CedarExprIfThenElse;

  const factory CedarExpr.set(List<CedarExpr> expressions) = CedarExprSet;

  const factory CedarExpr.record(Map<String, CedarExpr> attributes) =
      CedarExprRecord;

  const factory CedarExpr.funcCall({
    required String fn,
    required List<CedarExpr> args,
  }) = CedarExprFunctionCall;

  operator +(CedarExpr rhs) => add(rhs);
  operator -(CedarExpr rhs) => subtract(rhs);
  operator *(CedarExpr rhs) => multiply(rhs);
  operator -() => negate();

  CedarOp get op;

  Object? valueToJson();

  R accept<R>(ExprVisitor<R> visitor);
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg);

  @nonVirtual
  Map<String, Object?> toJson() => {
        op.toJson(): valueToJson(),
      };

  @override
  String toString() => prettyJson(toJson());
}

final class CedarExprFunctionCall extends CedarExpr {
  const CedarExprFunctionCall({
    required this.fn,
    required this.args,
  });

  final String fn;
  final List<CedarExpr> args;

  @override
  CedarOpFunction get op => CedarOpFunction(fn);

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitFunctionCall(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitFunctionCall(this, arg);

  @override
  List<Map<String, Object?>> valueToJson() =>
      args.map((arg) => arg.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprFunctionCall &&
          fn == other.fn &&
          const ListEquality().equals(args, other.args);

  @override
  int get hashCode => Object.hash(fn, args);
}

final class CedarExprValue extends CedarExpr {
  const CedarExprValue(this.value);

  factory CedarExprValue.fromJson(Object? json) {
    return CedarExprValue(CedarValue.fromJson(json));
  }

  final CedarValue value;

  @override
  CedarOpCode get op => CedarOpCode.value;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitValue(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitValue(this, arg);

  @override
  Object? valueToJson() => value.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CedarExprValue && value == other.value;

  @override
  int get hashCode => Object.hash(op, value);
}

enum CedarVariable {
  principal,
  action,
  resource,
  context;
}

final class CedarExprVariable extends CedarExpr {
  const CedarExprVariable(this.variable);

  factory CedarExprVariable.fromJson(String json) {
    return CedarExprVariable(CedarVariable.values.byName(json));
  }

  final CedarVariable variable;

  @override
  CedarOpCode get op => CedarOpCode.variable;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitVariable(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitVariable(this, arg);

  @override
  String valueToJson() => variable.name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprVariable && variable == other.variable;

  @override
  int get hashCode => Object.hash(op, variable);
}

final class CedarExprSlot extends CedarExpr {
  const CedarExprSlot(this.slotId);

  factory CedarExprSlot.fromJson(String json) {
    return CedarExprSlot(CedarSlotId.fromJson(json));
  }

  final CedarSlotId slotId;

  @override
  CedarOpCode get op => CedarOpCode.slot;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitSlot(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitSlot(this, arg);

  @override
  String valueToJson() => slotId.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprSlot && slotId == other.slotId;

  @override
  int get hashCode => Object.hash(op, slotId);
}

final class CedarExprUnknown extends CedarExpr {
  const CedarExprUnknown(this.name);

  factory CedarExprUnknown.fromJson(Map<String, Object?> json) {
    return CedarExprUnknown(json['name'] as String);
  }

  final String name;

  @override
  CedarOpCode get op => CedarOpCode.unknown;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitUnknown(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitUnknown(this, arg);

  @override
  Map<String, Object?> valueToJson() => {
        'name': name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CedarExprUnknown && name == other.name;

  @override
  int get hashCode => Object.hash(op, name);
}

final class CedarExprNot extends CedarExpr {
  const CedarExprNot(this.arg);

  factory CedarExprNot.fromJson(Map<String, Object?> json) {
    return CedarExprNot(
      CedarExpr.fromJson(json['arg'] as Map<String, Object?>),
    );
  }

  final CedarExpr arg;

  @override
  CedarOpCode get op => CedarOpCode.not;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitNot(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitNot(this, arg);

  @override
  Map<String, Object?> valueToJson() => {
        'arg': arg.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CedarExprNot && arg == other.arg;

  @override
  int get hashCode => Object.hash(op, arg);
}

final class CedarExprNegate extends CedarExpr {
  const CedarExprNegate(this.arg);

  factory CedarExprNegate.fromJson(Map<String, Object?> json) {
    return CedarExprNegate(
      CedarExpr.fromJson(json['arg'] as Map<String, Object?>),
    );
  }

  final CedarExpr arg;

  @override
  CedarOpCode get op => CedarOpCode.neg;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitNegate(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitNegate(this, arg);

  @override
  Map<String, Object?> valueToJson() => {
        'arg': arg.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CedarExprNegate && arg == other.arg;

  @override
  int get hashCode => Object.hash(op, arg);
}

sealed class CedarBinaryExpr extends CedarExpr {
  const CedarBinaryExpr({
    required this.left,
    required this.right,
  });

  final CedarExpr left;
  final CedarExpr right;

  @nonVirtual
  @override
  Map<String, Object?> valueToJson() => {
        'left': left.toJson(),
        'right': right.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarBinaryExpr &&
          op == other.op &&
          left == other.left &&
          right == other.right;

  @override
  int get hashCode => Object.hash(op, left, right);
}

final class CedarExprEquals extends CedarBinaryExpr {
  const CedarExprEquals({
    required super.left,
    required super.right,
  });

  factory CedarExprEquals.fromJson(Map<String, Object?> json) {
    return CedarExprEquals(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.equals;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitEquals(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitEquals(this, arg);
}

final class CedarExprNotEquals extends CedarBinaryExpr {
  const CedarExprNotEquals({
    required super.left,
    required super.right,
  });

  factory CedarExprNotEquals.fromJson(Map<String, Object?> json) {
    return CedarExprNotEquals(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.notEquals;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitNotEquals(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitNotEquals(this, arg);
}

final class CedarExprIn extends CedarBinaryExpr {
  const CedarExprIn({
    required super.left,
    required super.right,
  });

  factory CedarExprIn.fromJson(Map<String, Object?> json) {
    return CedarExprIn(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.in$;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitIn(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitIn(this, arg);
}

final class CedarExprLessThan extends CedarBinaryExpr {
  const CedarExprLessThan({
    required super.left,
    required super.right,
  });

  factory CedarExprLessThan.fromJson(Map<String, Object?> json) {
    return CedarExprLessThan(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.lessThan;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitLessThan(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitLessThan(this, arg);
}

final class CedarExprLessThanOrEquals extends CedarBinaryExpr {
  const CedarExprLessThanOrEquals({
    required super.left,
    required super.right,
  });

  factory CedarExprLessThanOrEquals.fromJson(Map<String, Object?> json) {
    return CedarExprLessThanOrEquals(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.lessThanOrEquals;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitLessThanOrEquals(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitLessThanOrEquals(this, arg);
}

final class CedarExprGreaterThan extends CedarBinaryExpr {
  const CedarExprGreaterThan({
    required super.left,
    required super.right,
  });

  factory CedarExprGreaterThan.fromJson(Map<String, Object?> json) {
    return CedarExprGreaterThan(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.greaterThan;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitGreaterThan(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitGreaterThan(this, arg);
}

final class CedarExprGreaterThanOrEquals extends CedarBinaryExpr {
  const CedarExprGreaterThanOrEquals({
    required super.left,
    required super.right,
  });

  factory CedarExprGreaterThanOrEquals.fromJson(Map<String, Object?> json) {
    return CedarExprGreaterThanOrEquals(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.greaterThanOrEquals;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitGreaterThanOrEquals(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitGreaterThanOrEquals(this, arg);
}

final class CedarExprAnd extends CedarBinaryExpr {
  const CedarExprAnd({
    required super.left,
    required super.right,
  });

  factory CedarExprAnd.fromJson(Map<String, Object?> json) {
    return CedarExprAnd(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.and;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitAnd(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitAnd(this, arg);
}

final class CedarExprOr extends CedarBinaryExpr {
  const CedarExprOr({
    required super.left,
    required super.right,
  });

  factory CedarExprOr.fromJson(Map<String, Object?> json) {
    return CedarExprOr(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.or;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitOr(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitOr(this, arg);
}

final class CedarExprPlus extends CedarBinaryExpr {
  const CedarExprPlus({
    required super.left,
    required super.right,
  });

  factory CedarExprPlus.fromJson(Map<String, Object?> json) {
    return CedarExprPlus(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.plus;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitPlus(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitPlus(this, arg);
}

final class CedarExprMinus extends CedarBinaryExpr {
  const CedarExprMinus({
    required super.left,
    required super.right,
  });

  factory CedarExprMinus.fromJson(Map<String, Object?> json) {
    return CedarExprMinus(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.minus;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitMinus(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitMinus(this, arg);
}

final class CedarExprTimes extends CedarBinaryExpr {
  const CedarExprTimes({
    required super.left,
    required super.right,
  });

  factory CedarExprTimes.fromJson(Map<String, Object?> json) {
    return CedarExprTimes(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.times;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitTimes(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitTimes(this, arg);
}

final class CedarExprContains extends CedarBinaryExpr {
  const CedarExprContains({
    required super.left,
    required super.right,
  });

  factory CedarExprContains.fromJson(Map<String, Object?> json) {
    return CedarExprContains(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.contains;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitContains(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitContains(this, arg);
}

final class CedarExprContainsAll extends CedarBinaryExpr {
  const CedarExprContainsAll({
    required super.left,
    required super.right,
  });

  factory CedarExprContainsAll.fromJson(Map<String, Object?> json) {
    return CedarExprContainsAll(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.containsAll;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitContainsAll(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitContainsAll(this, arg);
}

final class CedarExprContainsAny extends CedarBinaryExpr {
  const CedarExprContainsAny({
    required super.left,
    required super.right,
  });

  factory CedarExprContainsAny.fromJson(Map<String, Object?> json) {
    return CedarExprContainsAny(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      right: CedarExpr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  CedarOpCode get op => CedarOpCode.containsAny;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitContainsAny(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitContainsAny(this, arg);
}

sealed class CedarStringExpr extends CedarExpr {
  const CedarStringExpr();

  CedarExpr get left;
  String get attr;
}

final class CedarExprGetAttribute extends CedarStringExpr {
  const CedarExprGetAttribute({
    required this.left,
    required this.attr,
  });

  factory CedarExprGetAttribute.fromJson(Map<String, Object?> json) {
    return CedarExprGetAttribute(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      attr: json['attr'] as String,
    );
  }

  @override
  final CedarExpr left;

  @override
  final String attr;

  @override
  CedarOpCode get op => CedarOpCode.getAttribute;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitGetAttribute(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitGetAttribute(this, arg);

  @override
  Map<String, Object?> valueToJson() => {
        'left': left.toJson(),
        'attr': attr,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprGetAttribute &&
          left == other.left &&
          attr == other.attr;

  @override
  int get hashCode => Object.hash(op, left, attr);
}

final class CedarExprHasAttribute extends CedarStringExpr {
  const CedarExprHasAttribute({
    required this.left,
    required this.attr,
  });

  factory CedarExprHasAttribute.fromJson(Map<String, Object?> json) {
    return CedarExprHasAttribute(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      attr: json['attr'] as String,
    );
  }

  @override
  final CedarExpr left;

  @override
  final String attr;

  @override
  CedarOpCode get op => CedarOpCode.hasAttribute;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitHasAttribute(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitHasAttribute(this, arg);

  @override
  Map<String, Object?> valueToJson() => {
        'left': left.toJson(),
        'attr': attr,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprHasAttribute &&
          left == other.left &&
          attr == other.attr;

  @override
  int get hashCode => Object.hash(op, left, attr);
}

final class CedarExprLike extends CedarExpr {
  const CedarExprLike({
    required this.left,
    required this.pattern,
  });

  factory CedarExprLike.fromJson(Map<String, Object?> json) {
    return CedarExprLike(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      pattern: CedarPattern.parse(json['pattern'] as String),
    );
  }

  final CedarExpr left;
  final CedarPattern pattern;

  @override
  CedarOpCode get op => CedarOpCode.like;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitLike(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitLike(this, arg);

  @override
  Map<String, Object?> valueToJson() => {
        'left': left.toJson(),
        'pattern': pattern.toString(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprLike && left == other.left && pattern == other.pattern;

  @override
  int get hashCode => Object.hash(op, left, pattern);
}

final class CedarExprIs extends CedarExpr {
  const CedarExprIs({
    required this.left,
    required this.entityType,
    this.inExpr,
  });

  factory CedarExprIs.fromJson(Map<String, Object?> json) {
    return CedarExprIs(
      left: CedarExpr.fromJson(json['left'] as Map<String, Object?>),
      entityType: ['entity_type'] as String,
      inExpr: json['in'] != null
          ? CedarExpr.fromJson(json['in'] as Map<String, Object?>)
          : null,
    );
  }

  final CedarExpr left;
  final String entityType;
  final CedarExpr? inExpr;

  @override
  CedarOpCode get op => CedarOpCode.is$;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitIs(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitIs(this, arg);

  @override
  Map<String, Object?> valueToJson() => {
        'left': left.toJson(),
        'entity_type': entityType,
        if (inExpr case final inExpr?) 'in': inExpr.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprIs &&
          left == other.left &&
          entityType == other.entityType &&
          inExpr == other.inExpr;

  @override
  int get hashCode => Object.hash(op, left, entityType, inExpr);
}

final class CedarExprIfThenElse extends CedarExpr {
  const CedarExprIfThenElse({
    required this.cond,
    required this.then,
    required this.else$,
  });

  factory CedarExprIfThenElse.fromJson(Map<String, Object?> json) {
    return CedarExprIfThenElse(
      cond: CedarExpr.fromJson(json['if'] as Map<String, Object?>),
      then: CedarExpr.fromJson(json['then'] as Map<String, Object?>),
      else$: CedarExpr.fromJson(json['else'] as Map<String, Object?>),
    );
  }

  final CedarExpr cond;
  final CedarExpr then;
  final CedarExpr else$;

  @override
  CedarOpCode get op => CedarOpCode.ifThenElse;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitIfThenElse(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitIfThenElse(this, arg);

  @override
  Map<String, Object?> valueToJson() => {
        'if': cond.toJson(),
        'then': then.toJson(),
        'else': else$.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprIfThenElse &&
          cond == other.cond &&
          then == other.then &&
          else$ == other.else$;

  @override
  int get hashCode => Object.hash(op, cond, then, else$);
}

final class CedarExprSet extends CedarExpr {
  const CedarExprSet(this.expressions);

  factory CedarExprSet.fromJson(List<Object?> json) {
    return CedarExprSet([
      for (final expression in json)
        CedarExpr.fromJson(expression as Map<String, Object?>)
    ]);
  }

  final List<CedarExpr> expressions;

  @override
  CedarOpCode get op => CedarOpCode.set;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitSet(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitSet(this, arg);

  @override
  List<Object?> valueToJson() => [
        for (final expression in expressions) expression.toJson(),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprSet &&
          const UnorderedIterableEquality()
              .equals(expressions, other.expressions);

  @override
  int get hashCode => Object.hashAllUnordered(expressions);
}

final class CedarExprRecord extends CedarExpr {
  const CedarExprRecord(this.attributes);

  factory CedarExprRecord.fromJson(Map<String, Object?> json) {
    return CedarExprRecord({
      for (final entry in json.entries)
        entry.key: CedarExpr.fromJson(entry.value as Map<String, Object?>)
    });
  }

  final Map<String, CedarExpr> attributes;

  @override
  CedarOpCode get op => CedarOpCode.record;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitRecord(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitRecord(this, arg);

  @override
  Map<String, Object?> valueToJson() => {
        for (final entry in attributes.entries) entry.key: entry.value.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExprRecord &&
          const MapEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => const MapEquality().hash(attributes);
}
