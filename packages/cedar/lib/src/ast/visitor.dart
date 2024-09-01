import 'package:cedar/ast.dart';

abstract interface class ExprVisitor<R> {
  R visitValue(CedarExprValue value);
  R visitVariable(CedarExprVariable variable);
  R visitSlot(CedarExprSlot slot);
  R visitUnknown(CedarExprUnknown unknown);
  R visitNot(CedarExprNot not);
  R visitNegate(CedarExprNegate negate);
  R visitAnd(CedarExprAnd and);
  R visitOr(CedarExprOr or);
  R visitEquals(CedarExprEquals equals);
  R visitNotEquals(CedarExprNotEquals notEquals);
  R visitLessThan(CedarExprLessThan lessThan);
  R visitLessThanOrEquals(CedarExprLessThanOrEquals lessThanOrEquals);
  R visitGreaterThan(CedarExprGreaterThan greaterThan);
  R visitGreaterThanOrEquals(CedarExprGreaterThanOrEquals greaterThanOrEquals);
  R visitPlus(CedarExprPlus plus);
  R visitMinus(CedarExprMinus minus);
  R visitTimes(CedarExprTimes times);
  R visitContains(CedarExprContains contains);
  R visitContainsAll(CedarExprContainsAll containsAll);
  R visitContainsAny(CedarExprContainsAny containsAny);
  R visitGetAttribute(CedarExprGetAttribute getAttribute);
  R visitHasAttribute(CedarExprHasAttribute hasAttribute);
  R visitFunctionCall(CedarExprFunctionCall extensionCall);
  R visitSet(CedarExprSet set);
  R visitRecord(CedarExprRecord record);
  R visitLike(CedarExprLike like);
  R visitIn(CedarExprIn in_);
  R visitIs(CedarExprIs is_);
  R visitIfThenElse(CedarExprIfThenElse ifThenElse);
}

abstract base class DefaultExprVisitor<R> implements ExprVisitor<R?> {
  @override
  R? visitValue(CedarExprValue value) => null;
  @override
  R? visitVariable(CedarExprVariable variable) => null;
  @override
  R? visitSlot(CedarExprSlot slot) => null;
  @override
  R? visitUnknown(CedarExprUnknown unknown) => null;
  @override
  R? visitNot(CedarExprNot not) => null;
  @override
  R? visitNegate(CedarExprNegate negate) => null;
  @override
  R? visitAnd(CedarExprAnd and) => null;
  @override
  R? visitOr(CedarExprOr or) => null;
  @override
  R? visitEquals(CedarExprEquals equals) => null;
  @override
  R? visitNotEquals(CedarExprNotEquals notEquals) => null;
  @override
  R? visitLessThan(CedarExprLessThan lessThan) => null;
  @override
  R? visitLessThanOrEquals(CedarExprLessThanOrEquals lessThanOrEquals) => null;
  @override
  R? visitGreaterThan(CedarExprGreaterThan greaterThan) => null;
  @override
  R? visitGreaterThanOrEquals(
          CedarExprGreaterThanOrEquals greaterThanOrEquals) =>
      null;
  @override
  R? visitPlus(CedarExprPlus plus) => null;
  @override
  R? visitMinus(CedarExprMinus minus) => null;
  @override
  R? visitTimes(CedarExprTimes times) => null;
  @override
  R? visitContains(CedarExprContains contains) => null;
  @override
  R? visitContainsAll(CedarExprContainsAll containsAll) => null;
  @override
  R? visitContainsAny(CedarExprContainsAny containsAny) => null;
  @override
  R? visitGetAttribute(CedarExprGetAttribute getAttribute) => null;
  @override
  R? visitHasAttribute(CedarExprHasAttribute hasAttribute) => null;
  @override
  R? visitFunctionCall(CedarExprFunctionCall extensionCall) => null;
  @override
  R? visitSet(CedarExprSet set) => null;
  @override
  R? visitRecord(CedarExprRecord record) => null;
  @override
  R? visitLike(CedarExprLike like) => null;
  @override
  R? visitIn(CedarExprIn in_) => null;
  @override
  R? visitIs(CedarExprIs is_) => null;
  @override
  R? visitIfThenElse(CedarExprIfThenElse ifThenElse) => null;
}

abstract interface class ExprVisitorWithArg<R, A> {
  R visitValue(CedarExprValue value, A arg);
  R visitVariable(CedarExprVariable variable, A arg);
  R visitSlot(CedarExprSlot slot, A arg);
  R visitUnknown(CedarExprUnknown unknown, A arg);
  R visitNot(CedarExprNot not, A arg);
  R visitNegate(CedarExprNegate negate, A arg);
  R visitAnd(CedarExprAnd and, A arg);
  R visitOr(CedarExprOr or, A arg);
  R visitEquals(CedarExprEquals equals, A arg);
  R visitNotEquals(CedarExprNotEquals notEquals, A arg);
  R visitLessThan(CedarExprLessThan lessThan, A arg);
  R visitLessThanOrEquals(CedarExprLessThanOrEquals lessThanOrEquals, A arg);
  R visitGreaterThan(CedarExprGreaterThan greaterThan, A arg);
  R visitGreaterThanOrEquals(
      CedarExprGreaterThanOrEquals greaterThanOrEquals, A arg);
  R visitPlus(CedarExprPlus plus, A arg);
  R visitMinus(CedarExprMinus minus, A arg);
  R visitTimes(CedarExprTimes times, A arg);
  R visitContains(CedarExprContains contains, A arg);
  R visitContainsAll(CedarExprContainsAll containsAll, A arg);
  R visitContainsAny(CedarExprContainsAny containsAny, A arg);
  R visitGetAttribute(CedarExprGetAttribute getAttribute, A arg);
  R visitHasAttribute(CedarExprHasAttribute hasAttribute, A arg);
  R visitFunctionCall(CedarExprFunctionCall extensionCall, A arg);
  R visitSet(CedarExprSet set, A arg);
  R visitRecord(CedarExprRecord record, A arg);
  R visitLike(CedarExprLike like, A arg);
  R visitIn(CedarExprIn in_, A arg);
  R visitIs(CedarExprIs is_, A arg);
  R visitIfThenElse(CedarExprIfThenElse ifThenElse, A arg);
}
