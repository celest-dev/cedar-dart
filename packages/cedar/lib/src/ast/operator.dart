import 'package:cedar/src/ast.dart';

extension Comparison on Expr {
  Expr equals(Expr rhs) {
    return ExprEquals(left: this, right: rhs);
  }

  Expr notEquals(Expr rhs) {
    return ExprNotEquals(left: this, right: rhs);
  }

  Expr lessThan(Expr rhs) {
    return ExprLessThan(left: this, right: rhs);
  }

  Expr lessThanOrEquals(Expr rhs) {
    return ExprLessThanOrEquals(left: this, right: rhs);
  }

  Expr greaterThan(Expr rhs) {
    return ExprGreaterThan(left: this, right: rhs);
  }

  Expr greaterThanOrEquals(Expr rhs) {
    return ExprGreaterThanOrEquals(left: this, right: rhs);
  }

  // CedarExpr decimalLessThan(CedarExpr rhs) {
  //   return CedarExprExtensionCall.method(
  //     this,
  //     'lessThan',
  //     [rhs],
  //   );
  // }

  // CedarExpr decimalLessThanOrEquals(CedarExpr rhs) {
  //   return CedarExprExtensionCall.method(
  //     this,
  //     'lessThanOrEqual',
  //     [rhs],
  //   );
  // }

  // CedarExpr decimalGreaterThan(CedarExpr rhs) {
  //   return CedarExprExtensionCall.method(
  //     this,
  //     'greaterThan',
  //     [rhs],
  //   );
  // }

  // CedarExpr decimalGreaterThanOrEquals(CedarExpr rhs) {
  //   return CedarExprExtensionCall.method(
  //     this,
  //     'greaterThanOrEqual',
  //     [rhs],
  //   );
  // }

  Expr like(CedarPattern pattern) {
    return ExprLike(left: this, pattern: pattern);
  }
}

extension Logical on Expr {
  Expr and(Expr rhs) {
    return ExprAnd(left: this, right: rhs);
  }

  Expr or(Expr rhs) {
    return ExprOr(left: this, right: rhs);
  }

  Expr not() {
    return ExprNot(this);
  }

  Expr ifThenElse(
    Expr condition,
    Expr thenCedarExpr,
    Expr elseCedarExpr,
  ) {
    return ExprIfThenElse(
      cond: condition,
      then: thenCedarExpr,
      else$: elseCedarExpr,
    );
  }
}

Expr not(Expr expr) => Expr.not(expr);

Expr ifThenElse(
  Expr condition,
  Expr thenCedarExpr,
  Expr elseCedarExpr,
) =>
    ExprIfThenElse(
      cond: condition,
      then: thenCedarExpr,
      else$: elseCedarExpr,
    );

extension Arithmetic on Expr {
  Expr add(Expr rhs) {
    return ExprAdd(left: this, right: rhs);
  }

  Expr subtract(Expr rhs) {
    return ExprSubt(left: this, right: rhs);
  }

  Expr multiply(Expr rhs) {
    return ExprMult(left: this, right: rhs);
  }

  Expr negate() {
    return ExprNegate(this);
  }
}

extension Hierarchy on Expr {
  Expr in_(Expr rhs) {
    return ExprIn(left: this, right: rhs);
  }

  Expr is_(String entityType) {
    return ExprIs(left: this, entityType: entityType);
  }

  Expr isIn(String entityType, Expr rhs) {
    return ExprIs(left: this, entityType: entityType, inExpr: rhs);
  }

  Expr contains(Expr rhs) {
    return ExprContains(left: this, right: rhs);
  }

  Expr containsAll(Expr rhs) {
    return ExprContainsAll(left: this, right: rhs);
  }

  Expr containsAny(Expr rhs) {
    return ExprContainsAny(left: this, right: rhs);
  }

  Expr access(String attr) {
    return ExprGetAttribute(left: this, attr: attr);
  }

  Expr has(String attr) {
    return ExprHasAttribute(left: this, attr: attr);
  }
}

extension IpAddressOperators on Expr {
  Expr isIpv4() {
    return ExprExtensionCall(
      fn: 'isIpv4',
      args: [this],
    );
  }

  Expr isIpv6() {
    return ExprExtensionCall(
      fn: 'isIpv6',
      args: [this],
    );
  }

  Expr isMulticast() {
    return ExprExtensionCall(
      fn: 'isMulticast',
      args: [this],
    );
  }

  Expr isLoopback() {
    return ExprExtensionCall(
      fn: 'isLoopback',
      args: [this],
    );
  }

  Expr isInRange(Expr rhs) {
    return ExprExtensionCall(
      fn: 'isInRange',
      args: [this, rhs],
    );
  }
}
