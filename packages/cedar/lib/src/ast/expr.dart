/// Dart representation of the JSON expression language used in Cedar
/// policies.
///
/// See: https://docs.cedarpolicy.com/policies/json-format.html#JsonExpr-objects
library;

import 'package:cedar/cedar.dart';
import 'package:cedar/src/ast.dart';
import 'package:cedar/src/util/pretty_json.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

sealed class Op {
  factory Op.fromJson(String json) => switch (json) {
        'Value' => OpBuiltin.value,
        'Var' => OpBuiltin.variable,
        'Slot' => OpBuiltin.slot,
        'Unknown' => OpBuiltin.unknown,
        '!' => OpBuiltin.not,
        'neg' => OpBuiltin.neg,
        '==' => OpBuiltin.equals,
        '!=' => OpBuiltin.notEquals,
        'in' => OpBuiltin.in$,
        '<' => OpBuiltin.lessThan,
        '<=' => OpBuiltin.lessThanOrEquals,
        '>' => OpBuiltin.greaterThan,
        '>=' => OpBuiltin.greaterThanOrEquals,
        '&&' => OpBuiltin.and,
        '||' => OpBuiltin.or,
        '+' => OpBuiltin.plus,
        '-' => OpBuiltin.minus,
        '*' => OpBuiltin.times,
        'contains' => OpBuiltin.contains,
        'containsAll' => OpBuiltin.containsAll,
        'containsAny' => OpBuiltin.containsAny,
        '.' => OpBuiltin.getAttribute,
        'has' => OpBuiltin.hasAttribute,
        'like' => OpBuiltin.like,
        'is' => OpBuiltin.is$,
        'if-then-else' => OpBuiltin.ifThenElse,
        'Set' => OpBuiltin.set,
        'Record' => OpBuiltin.record,
        _ => OpExtension(json),
      };

  String toJson();
}

final class OpExtension implements Op {
  const OpExtension(this.name);

  final String name;

  @override
  String toJson() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OpExtension && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

enum OpBuiltin implements Op {
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

sealed class Expr {
  const Expr();

  factory Expr.fromJson(Map<String, Object?> json) {
    if (json.keys.length != 1) {
      throw FormatException('Expected exactly one key in JSON expression');
    }
    final MapEntry(:key, :value) = json.entries.first;
    final op = Op.fromJson(key);
    return switch (op) {
      OpBuiltin.value => ExprValue.fromJson(value),
      OpBuiltin.variable => ExprVariable.fromJson(value as String),
      OpBuiltin.slot => ExprSlot.fromJson(value as String),
      OpBuiltin.unknown => ExprUnknown.fromJson(value as Map<String, Object?>),
      OpBuiltin.not => ExprNot.fromJson(value as Map<String, Object?>),
      OpBuiltin.neg => ExprNegate.fromJson(value as Map<String, Object?>),
      OpBuiltin.equals => ExprEquals.fromJson(value as Map<String, Object?>),
      OpBuiltin.notEquals =>
        ExprNotEquals.fromJson(value as Map<String, Object?>),
      OpBuiltin.in$ => ExprIn.fromJson(value as Map<String, Object?>),
      OpBuiltin.lessThan =>
        ExprLessThan.fromJson(value as Map<String, Object?>),
      OpBuiltin.lessThanOrEquals =>
        ExprLessThanOrEquals.fromJson(value as Map<String, Object?>),
      OpBuiltin.greaterThan =>
        ExprGreaterThan.fromJson(value as Map<String, Object?>),
      OpBuiltin.greaterThanOrEquals =>
        ExprGreaterThanOrEquals.fromJson(value as Map<String, Object?>),
      OpBuiltin.and => ExprAnd.fromJson(value as Map<String, Object?>),
      OpBuiltin.or => ExprOr.fromJson(value as Map<String, Object?>),
      OpBuiltin.plus => ExprAdd.fromJson(value as Map<String, Object?>),
      OpBuiltin.minus => ExprSubt.fromJson(value as Map<String, Object?>),
      OpBuiltin.times => ExprMult.fromJson(value as Map<String, Object?>),
      OpBuiltin.contains =>
        ExprContains.fromJson(value as Map<String, Object?>),
      OpBuiltin.containsAll =>
        ExprContainsAll.fromJson(value as Map<String, Object?>),
      OpBuiltin.containsAny =>
        ExprContainsAny.fromJson(value as Map<String, Object?>),
      OpBuiltin.getAttribute =>
        ExprGetAttribute.fromJson(value as Map<String, Object?>),
      OpBuiltin.hasAttribute =>
        ExprHasAttribute.fromJson(value as Map<String, Object?>),
      OpBuiltin.like => ExprLike.fromJson(value as Map<String, Object?>),
      OpBuiltin.is$ => ExprIs.fromJson(value as Map<String, Object?>),
      OpBuiltin.ifThenElse =>
        ExprIfThenElse.fromJson(value as Map<String, Object?>),
      OpBuiltin.set => ExprSet.fromJson(value as List<Object?>),
      OpBuiltin.record => ExprRecord.fromJson(value as Map<String, Object?>),
      final OpExtension op => ExprExtensionCall(
          fn: op.name,
          args: (value as List<Object?>)
              .map((el) => Expr.fromJson(el as Map<String, Object?>))
              .toList(),
        ),
    };
  }

  const factory Expr.value(Value value) = ExprValue;

  const factory Expr.variable(CedarVariable variable) = ExprVariable;

  const factory Expr.slot(SlotId slotId) = ExprSlot;

  const factory Expr.unknown(String name) = ExprUnknown;

  const factory Expr.not(Expr arg) = ExprNot;

  const factory Expr.negate(Expr arg) = ExprNegate;

  const factory Expr.equals({
    required Expr left,
    required Expr right,
  }) = ExprEquals;

  const factory Expr.notEquals({
    required Expr left,
    required Expr right,
  }) = ExprNotEquals;

  const factory Expr.in_({
    required Expr left,
    required Expr right,
  }) = ExprIn;

  const factory Expr.lessThan({
    required Expr left,
    required Expr right,
  }) = ExprLessThan;

  const factory Expr.lessThanOrEquals({
    required Expr left,
    required Expr right,
  }) = ExprLessThanOrEquals;

  const factory Expr.greaterThan({
    required Expr left,
    required Expr right,
  }) = ExprGreaterThan;

  const factory Expr.greaterThanOrEquals({
    required Expr left,
    required Expr right,
  }) = ExprGreaterThanOrEquals;

  const factory Expr.and({
    required Expr left,
    required Expr right,
  }) = ExprAnd;

  const factory Expr.or({
    required Expr left,
    required Expr right,
  }) = ExprOr;

  const factory Expr.plus({
    required Expr left,
    required Expr right,
  }) = ExprAdd;

  const factory Expr.minus({
    required Expr left,
    required Expr right,
  }) = ExprSubt;

  const factory Expr.times({
    required Expr left,
    required Expr right,
  }) = ExprMult;

  const factory Expr.contains({
    required Expr left,
    required Expr right,
  }) = ExprContains;

  const factory Expr.containsAll({
    required Expr left,
    required Expr right,
  }) = ExprContainsAll;

  const factory Expr.containsAny({
    required Expr left,
    required Expr right,
  }) = ExprContainsAny;

  const factory Expr.getAttribute({
    required Expr left,
    required String attr,
  }) = ExprGetAttribute;

  const factory Expr.hasAttribute({
    required Expr left,
    required String attr,
  }) = ExprHasAttribute;

  const factory Expr.like({
    required Expr left,
    required CedarPattern pattern,
  }) = ExprLike;

  const factory Expr.is_({
    required Expr left,
    required String entityType,
    Expr? inExpr,
  }) = ExprIs;

  const factory Expr.ifThenElse({
    required Expr cond,
    required Expr then,
    required Expr else$,
  }) = ExprIfThenElse;

  const factory Expr.set(List<Expr> expressions) = ExprSet;

  const factory Expr.record(Map<String, Expr> attributes) = ExprRecord;

  const factory Expr.funcCall({
    required String fn,
    required List<Expr> args,
  }) = ExprExtensionCall;

  operator +(Expr rhs) => add(rhs);
  operator -(Expr rhs) => subtract(rhs);
  operator *(Expr rhs) => multiply(rhs);
  operator -() => negate();

  Op get op;

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

final class ExprExtensionCall extends Expr {
  const ExprExtensionCall({
    required this.fn,
    required this.args,
  });

  final String fn;
  final List<Expr> args;

  @override
  OpExtension get op => OpExtension(fn);

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitExtensionCall(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitExtensionCall(this, arg);

  @override
  List<Map<String, Object?>> valueToJson() =>
      args.map((arg) => arg.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExprExtensionCall &&
          fn == other.fn &&
          const ListEquality().equals(args, other.args);

  @override
  int get hashCode => Object.hash(fn, args);
}

final class ExprValue extends Expr {
  const ExprValue(this.value);

  factory ExprValue.fromJson(Object? json) {
    return ExprValue(Value.fromJson(json));
  }

  final Value value;

  @override
  OpBuiltin get op => OpBuiltin.value;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitValue(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitValue(this, arg);

  @override
  Object? valueToJson() => value.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExprValue && value == other.value;

  @override
  int get hashCode => Object.hash(op, value);
}

final class ExprVariable extends Expr {
  const ExprVariable(this.variable);

  factory ExprVariable.fromJson(String json) {
    return ExprVariable(CedarVariable.values.byName(json));
  }

  final CedarVariable variable;

  @override
  OpBuiltin get op => OpBuiltin.variable;

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
      other is ExprVariable && variable == other.variable;

  @override
  int get hashCode => Object.hash(op, variable);
}

final class ExprSlot extends Expr {
  const ExprSlot(this.slotId);

  factory ExprSlot.fromJson(String json) {
    return ExprSlot(SlotId.fromJson(json));
  }

  final SlotId slotId;

  @override
  OpBuiltin get op => OpBuiltin.slot;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitSlot(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitSlot(this, arg);

  @override
  String valueToJson() => slotId.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExprSlot && slotId == other.slotId;

  @override
  int get hashCode => Object.hash(op, slotId);
}

final class ExprUnknown extends Expr {
  const ExprUnknown(this.name);

  factory ExprUnknown.fromJson(Map<String, Object?> json) {
    return ExprUnknown(json['name'] as String);
  }

  final String name;

  @override
  OpBuiltin get op => OpBuiltin.unknown;

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
      identical(this, other) || other is ExprUnknown && name == other.name;

  @override
  int get hashCode => Object.hash(op, name);
}

final class ExprNot extends Expr {
  const ExprNot(this.arg);

  factory ExprNot.fromJson(Map<String, Object?> json) {
    return ExprNot(
      Expr.fromJson(json['arg'] as Map<String, Object?>),
    );
  }

  final Expr arg;

  @override
  OpBuiltin get op => OpBuiltin.not;

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
      identical(this, other) || other is ExprNot && arg == other.arg;

  @override
  int get hashCode => Object.hash(op, arg);
}

final class ExprNegate extends Expr {
  const ExprNegate(this.arg);

  factory ExprNegate.fromJson(Map<String, Object?> json) {
    return ExprNegate(
      Expr.fromJson(json['arg'] as Map<String, Object?>),
    );
  }

  final Expr arg;

  @override
  OpBuiltin get op => OpBuiltin.neg;

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
      identical(this, other) || other is ExprNegate && arg == other.arg;

  @override
  int get hashCode => Object.hash(op, arg);
}

sealed class CedarBinaryExpr extends Expr {
  const CedarBinaryExpr({
    required this.left,
    required this.right,
  });

  final Expr left;
  final Expr right;

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

final class ExprEquals extends CedarBinaryExpr {
  const ExprEquals({
    required super.left,
    required super.right,
  });

  factory ExprEquals.fromJson(Map<String, Object?> json) {
    return ExprEquals(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.equals;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitEquals(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitEquals(this, arg);
}

final class ExprNotEquals extends CedarBinaryExpr {
  const ExprNotEquals({
    required super.left,
    required super.right,
  });

  factory ExprNotEquals.fromJson(Map<String, Object?> json) {
    return ExprNotEquals(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.notEquals;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitNotEquals(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitNotEquals(this, arg);
}

final class ExprIn extends CedarBinaryExpr {
  const ExprIn({
    required super.left,
    required super.right,
  });

  factory ExprIn.fromJson(Map<String, Object?> json) {
    return ExprIn(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.in$;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitIn(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitIn(this, arg);
}

final class ExprLessThan extends CedarBinaryExpr {
  const ExprLessThan({
    required super.left,
    required super.right,
  });

  factory ExprLessThan.fromJson(Map<String, Object?> json) {
    return ExprLessThan(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.lessThan;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitLessThan(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitLessThan(this, arg);
}

final class ExprLessThanOrEquals extends CedarBinaryExpr {
  const ExprLessThanOrEquals({
    required super.left,
    required super.right,
  });

  factory ExprLessThanOrEquals.fromJson(Map<String, Object?> json) {
    return ExprLessThanOrEquals(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.lessThanOrEquals;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitLessThanOrEquals(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitLessThanOrEquals(this, arg);
}

final class ExprGreaterThan extends CedarBinaryExpr {
  const ExprGreaterThan({
    required super.left,
    required super.right,
  });

  factory ExprGreaterThan.fromJson(Map<String, Object?> json) {
    return ExprGreaterThan(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.greaterThan;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitGreaterThan(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitGreaterThan(this, arg);
}

final class ExprGreaterThanOrEquals extends CedarBinaryExpr {
  const ExprGreaterThanOrEquals({
    required super.left,
    required super.right,
  });

  factory ExprGreaterThanOrEquals.fromJson(Map<String, Object?> json) {
    return ExprGreaterThanOrEquals(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.greaterThanOrEquals;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitGreaterThanOrEquals(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitGreaterThanOrEquals(this, arg);
}

final class ExprAnd extends CedarBinaryExpr {
  const ExprAnd({
    required super.left,
    required super.right,
  });

  factory ExprAnd.fromJson(Map<String, Object?> json) {
    return ExprAnd(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.and;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitAnd(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitAnd(this, arg);
}

final class ExprOr extends CedarBinaryExpr {
  const ExprOr({
    required super.left,
    required super.right,
  });

  factory ExprOr.fromJson(Map<String, Object?> json) {
    return ExprOr(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.or;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitOr(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitOr(this, arg);
}

final class ExprAdd extends CedarBinaryExpr {
  const ExprAdd({
    required super.left,
    required super.right,
  });

  factory ExprAdd.fromJson(Map<String, Object?> json) {
    return ExprAdd(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.plus;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitAdd(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitAdd(this, arg);
}

final class ExprSubt extends CedarBinaryExpr {
  const ExprSubt({
    required super.left,
    required super.right,
  });

  factory ExprSubt.fromJson(Map<String, Object?> json) {
    return ExprSubt(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.minus;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitSubt(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitSubt(this, arg);
}

final class ExprMult extends CedarBinaryExpr {
  const ExprMult({
    required super.left,
    required super.right,
  });

  factory ExprMult.fromJson(Map<String, Object?> json) {
    return ExprMult(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.times;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitMult(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitMult(this, arg);
}

final class ExprContains extends CedarBinaryExpr {
  const ExprContains({
    required super.left,
    required super.right,
  });

  factory ExprContains.fromJson(Map<String, Object?> json) {
    return ExprContains(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.contains;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitContains(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitContains(this, arg);
}

final class ExprContainsAll extends CedarBinaryExpr {
  const ExprContainsAll({
    required super.left,
    required super.right,
  });

  factory ExprContainsAll.fromJson(Map<String, Object?> json) {
    return ExprContainsAll(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.containsAll;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitContainsAll(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitContainsAll(this, arg);
}

final class ExprContainsAny extends CedarBinaryExpr {
  const ExprContainsAny({
    required super.left,
    required super.right,
  });

  factory ExprContainsAny.fromJson(Map<String, Object?> json) {
    return ExprContainsAny(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      right: Expr.fromJson(json['right'] as Map<String, Object?>),
    );
  }

  @override
  OpBuiltin get op => OpBuiltin.containsAny;

  @override
  R accept<R>(ExprVisitor<R> visitor) => visitor.visitContainsAny(this);

  @override
  R acceptWithArg<R, A>(ExprVisitorWithArg<R, A> visitor, A arg) =>
      visitor.visitContainsAny(this, arg);
}

sealed class CedarStringExpr extends Expr {
  const CedarStringExpr();

  Expr get left;
  String get attr;
}

final class ExprGetAttribute extends CedarStringExpr {
  const ExprGetAttribute({
    required this.left,
    required this.attr,
  });

  factory ExprGetAttribute.fromJson(Map<String, Object?> json) {
    return ExprGetAttribute(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      attr: json['attr'] as String,
    );
  }

  @override
  final Expr left;

  @override
  final String attr;

  @override
  OpBuiltin get op => OpBuiltin.getAttribute;

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
      other is ExprGetAttribute && left == other.left && attr == other.attr;

  @override
  int get hashCode => Object.hash(op, left, attr);
}

final class ExprHasAttribute extends CedarStringExpr {
  const ExprHasAttribute({
    required this.left,
    required this.attr,
  });

  factory ExprHasAttribute.fromJson(Map<String, Object?> json) {
    return ExprHasAttribute(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      attr: json['attr'] as String,
    );
  }

  @override
  final Expr left;

  @override
  final String attr;

  @override
  OpBuiltin get op => OpBuiltin.hasAttribute;

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
      other is ExprHasAttribute && left == other.left && attr == other.attr;

  @override
  int get hashCode => Object.hash(op, left, attr);
}

final class ExprLike extends Expr {
  const ExprLike({
    required this.left,
    required this.pattern,
  });

  factory ExprLike.fromJson(Map<String, Object?> json) {
    return ExprLike(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      pattern: CedarPattern.parse(json['pattern'] as String),
    );
  }

  final Expr left;
  final CedarPattern pattern;

  @override
  OpBuiltin get op => OpBuiltin.like;

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
      other is ExprLike && left == other.left && pattern == other.pattern;

  @override
  int get hashCode => Object.hash(op, left, pattern);
}

final class ExprIs extends Expr {
  const ExprIs({
    required this.left,
    required this.entityType,
    this.inExpr,
  });

  factory ExprIs.fromJson(Map<String, Object?> json) {
    return ExprIs(
      left: Expr.fromJson(json['left'] as Map<String, Object?>),
      entityType: ['entity_type'] as String,
      inExpr: json['in'] != null
          ? Expr.fromJson(json['in'] as Map<String, Object?>)
          : null,
    );
  }

  final Expr left;
  final String entityType;
  final Expr? inExpr;

  @override
  OpBuiltin get op => OpBuiltin.is$;

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
      other is ExprIs &&
          left == other.left &&
          entityType == other.entityType &&
          inExpr == other.inExpr;

  @override
  int get hashCode => Object.hash(op, left, entityType, inExpr);
}

final class ExprIfThenElse extends Expr {
  const ExprIfThenElse({
    required this.cond,
    required this.then,
    required this.else$,
  });

  factory ExprIfThenElse.fromJson(Map<String, Object?> json) {
    return ExprIfThenElse(
      cond: Expr.fromJson(json['if'] as Map<String, Object?>),
      then: Expr.fromJson(json['then'] as Map<String, Object?>),
      else$: Expr.fromJson(json['else'] as Map<String, Object?>),
    );
  }

  final Expr cond;
  final Expr then;
  final Expr else$;

  @override
  OpBuiltin get op => OpBuiltin.ifThenElse;

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
      other is ExprIfThenElse &&
          cond == other.cond &&
          then == other.then &&
          else$ == other.else$;

  @override
  int get hashCode => Object.hash(op, cond, then, else$);
}

final class ExprSet extends Expr {
  const ExprSet(this.expressions);

  factory ExprSet.fromJson(List<Object?> json) {
    return ExprSet([
      for (final expression in json)
        Expr.fromJson(expression as Map<String, Object?>)
    ]);
  }

  final List<Expr> expressions;

  @override
  OpBuiltin get op => OpBuiltin.set;

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
      other is ExprSet &&
          const UnorderedIterableEquality()
              .equals(expressions, other.expressions);

  @override
  int get hashCode => Object.hashAllUnordered(expressions);
}

final class ExprRecord extends Expr {
  const ExprRecord(this.attributes);

  factory ExprRecord.fromJson(Map<String, Object?> json) {
    return ExprRecord({
      for (final entry in json.entries)
        entry.key: Expr.fromJson(entry.value as Map<String, Object?>)
    });
  }

  final Map<String, Expr> attributes;

  @override
  OpBuiltin get op => OpBuiltin.record;

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
      other is ExprRecord &&
          const MapEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => const MapEquality().hash(attributes);
}
