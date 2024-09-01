import 'package:cedar/src/ast.dart';
import 'package:cedar/src/ast/expr.dart';

extension Comparison on CedarExpr {
  CedarExpr equals(CedarExpr rhs) {
    return CedarExprEquals(left: this, right: rhs);
  }

  CedarExpr notEquals(CedarExpr rhs) {
    return CedarExprNotEquals(left: this, right: rhs);
  }

  CedarExpr lessThan(CedarExpr rhs) {
    return CedarExprLessThan(left: this, right: rhs);
  }

  CedarExpr lessThanOrEquals(CedarExpr rhs) {
    return CedarExprLessThanOrEquals(left: this, right: rhs);
  }

  CedarExpr greaterThan(CedarExpr rhs) {
    return CedarExprGreaterThan(left: this, right: rhs);
  }

  CedarExpr greaterThanOrEquals(CedarExpr rhs) {
    return CedarExprGreaterThanOrEquals(left: this, right: rhs);
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

  CedarExpr like(CedarPattern pattern) {
    return CedarExprLike(left: this, pattern: pattern);
  }
}

extension Logical on CedarExpr {
  CedarExpr and(CedarExpr rhs) {
    return CedarExprAnd(left: this, right: rhs);
  }

  CedarExpr or(CedarExpr rhs) {
    return CedarExprOr(left: this, right: rhs);
  }

  CedarExpr not() {
    return CedarExprNot(this);
  }

  CedarExpr ifThenElse(
    CedarExpr condition,
    CedarExpr thenCedarExpr,
    CedarExpr elseCedarExpr,
  ) {
    return CedarExprIfThenElse(
      cond: condition,
      then: thenCedarExpr,
      else$: elseCedarExpr,
    );
  }
}

CedarExpr not(CedarExpr expr) => CedarExpr.not(expr);

CedarExpr ifThenElse(
  CedarExpr condition,
  CedarExpr thenCedarExpr,
  CedarExpr elseCedarExpr,
) =>
    CedarExprIfThenElse(
      cond: condition,
      then: thenCedarExpr,
      else$: elseCedarExpr,
    );

extension Arithmetic on CedarExpr {
  CedarExpr add(CedarExpr rhs) {
    return CedarExprPlus(left: this, right: rhs);
  }

  CedarExpr subtract(CedarExpr rhs) {
    return CedarExprMinus(left: this, right: rhs);
  }

  CedarExpr multiply(CedarExpr rhs) {
    return CedarExprTimes(left: this, right: rhs);
  }

  CedarExpr negate() {
    return CedarExprNegate(this);
  }
}

extension Hierarchy on CedarExpr {
  CedarExpr in_(CedarExpr rhs) {
    return CedarExprIn(left: this, right: rhs);
  }

  CedarExpr is_(String entityType) {
    return CedarExprIs(left: this, entityType: entityType);
  }

  CedarExpr isIn(String entityType, CedarExpr rhs) {
    return CedarExprIs(left: this, entityType: entityType, inExpr: rhs);
  }

  CedarExpr contains(CedarExpr rhs) {
    return CedarExprContains(left: this, right: rhs);
  }

  CedarExpr containsAll(CedarExpr rhs) {
    return CedarExprContainsAll(left: this, right: rhs);
  }

  CedarExpr containsAny(CedarExpr rhs) {
    return CedarExprContainsAny(left: this, right: rhs);
  }

  CedarExpr access(String attr) {
    return CedarExprGetAttribute(left: this, attr: attr);
  }

  CedarExpr has(String attr) {
    return CedarExprHasAttribute(left: this, attr: attr);
  }
}

extension IpAddressOperators on CedarExpr {
  CedarExpr isIpv4() {
    return CedarExprFunctionCall(
      fn: 'isIpv4',
      args: [this],
    );
  }

  CedarExpr isIpv6() {
    return CedarExprFunctionCall(
      fn: 'isIpv6',
      args: [this],
    );
  }

  CedarExpr isMulticast() {
    return CedarExprFunctionCall(
      fn: 'isMulticast',
      args: [this],
    );
  }

  CedarExpr isLoopback() {
    return CedarExprFunctionCall(
      fn: 'isLoopback',
      args: [this],
    );
  }

  CedarExpr isInRange(CedarExpr rhs) {
    return CedarExprFunctionCall(
      fn: 'isInRange',
      args: [this, rhs],
    );
  }
}
