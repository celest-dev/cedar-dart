import 'package:cedar/ast.dart';

abstract interface class ExprVisitor<R> {
  R visitValue(ExprValue value);
  R visitVariable(ExprVariable variable);
  R visitSlot(ExprSlot slot);
  R visitUnknown(ExprUnknown unknown);
  R visitNot(ExprNot not);
  R visitNegate(ExprNegate negate);
  R visitAnd(ExprAnd and);
  R visitOr(ExprOr or);
  R visitEquals(ExprEquals equals);
  R visitNotEquals(ExprNotEquals notEquals);
  R visitLessThan(ExprLessThan lessThan);
  R visitLessThanOrEquals(ExprLessThanOrEquals lessThanOrEquals);
  R visitGreaterThan(ExprGreaterThan greaterThan);
  R visitGreaterThanOrEquals(ExprGreaterThanOrEquals greaterThanOrEquals);
  R visitAdd(ExprAdd add);
  R visitSubt(ExprSubt subt);
  R visitMult(ExprMult mult);
  R visitContains(ExprContains contains);
  R visitContainsAll(ExprContainsAll containsAll);
  R visitContainsAny(ExprContainsAny containsAny);
  R visitGetAttribute(ExprGetAttribute getAttribute);
  R visitHasAttribute(ExprHasAttribute hasAttribute);
  R visitExtensionCall(ExprExtensionCall extensionCall);
  R visitSet(ExprSet set);
  R visitRecord(ExprRecord record);
  R visitLike(ExprLike like);
  R visitIn(ExprIn in_);
  R visitIs(ExprIs is_);
  R visitIfThenElse(ExprIfThenElse ifThenElse);
}

abstract base class DefaultExprVisitor<R> implements ExprVisitor<R?> {
  @override
  R? visitValue(ExprValue value) => null;
  @override
  R? visitVariable(ExprVariable variable) => null;
  @override
  R? visitSlot(ExprSlot slot) => null;
  @override
  R? visitUnknown(ExprUnknown unknown) => null;
  @override
  R? visitNot(ExprNot not) => null;
  @override
  R? visitNegate(ExprNegate negate) => null;
  @override
  R? visitAnd(ExprAnd and) => null;
  @override
  R? visitOr(ExprOr or) => null;
  @override
  R? visitEquals(ExprEquals equals) => null;
  @override
  R? visitNotEquals(ExprNotEquals notEquals) => null;
  @override
  R? visitLessThan(ExprLessThan lessThan) => null;
  @override
  R? visitLessThanOrEquals(ExprLessThanOrEquals lessThanOrEquals) => null;
  @override
  R? visitGreaterThan(ExprGreaterThan greaterThan) => null;
  @override
  R? visitGreaterThanOrEquals(ExprGreaterThanOrEquals greaterThanOrEquals) =>
      null;
  @override
  R? visitAdd(ExprAdd add) => null;
  @override
  R? visitSubt(ExprSubt subt) => null;
  @override
  R? visitMult(ExprMult mult) => null;
  @override
  R? visitContains(ExprContains contains) => null;
  @override
  R? visitContainsAll(ExprContainsAll containsAll) => null;
  @override
  R? visitContainsAny(ExprContainsAny containsAny) => null;
  @override
  R? visitGetAttribute(ExprGetAttribute getAttribute) => null;
  @override
  R? visitHasAttribute(ExprHasAttribute hasAttribute) => null;
  @override
  R? visitExtensionCall(ExprExtensionCall extensionCall) => null;
  @override
  R? visitSet(ExprSet set) => null;
  @override
  R? visitRecord(ExprRecord record) => null;
  @override
  R? visitLike(ExprLike like) => null;
  @override
  R? visitIn(ExprIn in_) => null;
  @override
  R? visitIs(ExprIs is_) => null;
  @override
  R? visitIfThenElse(ExprIfThenElse ifThenElse) => null;
}

abstract interface class ExprVisitorWithArg<R, A> {
  R visitValue(ExprValue value, A arg);
  R visitVariable(ExprVariable variable, A arg);
  R visitSlot(ExprSlot slot, A arg);
  R visitUnknown(ExprUnknown unknown, A arg);
  R visitNot(ExprNot not, A arg);
  R visitNegate(ExprNegate negate, A arg);
  R visitAnd(ExprAnd and, A arg);
  R visitOr(ExprOr or, A arg);
  R visitEquals(ExprEquals equals, A arg);
  R visitNotEquals(ExprNotEquals notEquals, A arg);
  R visitLessThan(ExprLessThan lessThan, A arg);
  R visitLessThanOrEquals(ExprLessThanOrEquals lessThanOrEquals, A arg);
  R visitGreaterThan(ExprGreaterThan greaterThan, A arg);
  R visitGreaterThanOrEquals(
      ExprGreaterThanOrEquals greaterThanOrEquals, A arg);
  R visitAdd(ExprAdd add, A arg);
  R visitSubt(ExprSubt subt, A arg);
  R visitMult(ExprMult mult, A arg);
  R visitContains(ExprContains contains, A arg);
  R visitContainsAll(ExprContainsAll containsAll, A arg);
  R visitContainsAny(ExprContainsAny containsAny, A arg);
  R visitGetAttribute(ExprGetAttribute getAttribute, A arg);
  R visitHasAttribute(ExprHasAttribute hasAttribute, A arg);
  R visitExtensionCall(ExprExtensionCall extensionCall, A arg);
  R visitSet(ExprSet set, A arg);
  R visitRecord(ExprRecord record, A arg);
  R visitLike(ExprLike like, A arg);
  R visitIn(ExprIn in_, A arg);
  R visitIs(ExprIs is_, A arg);
  R visitIfThenElse(ExprIfThenElse ifThenElse, A arg);
}
