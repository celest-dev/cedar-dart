import 'package:cedar/src/ast.dart';
import 'package:fixnum/fixnum.dart';

Expr boolean(bool value) {
  return ExprValue(Value.bool(value));
}

Expr true_() {
  return boolean(true);
}

Expr false_() {
  return boolean(false);
}

Expr string(String value) {
  return ExprValue(Value.string(value));
}

Expr long(int value) {
  return ExprValue(Value.long(Int64(value)));
}

Expr set(Iterable<Expr> value) {
  return ExprSet(value.toList());
}

typedef Pair = (String key, Expr value);

Expr record(Iterable<Pair> pairs) {
  return ExprRecord({
    for (final (key, value) in pairs) key: value,
  });
}

Expr entityUid(String type, String id) {
  return ExprValue(Value.entity(uid: EntityUid.of(type, id)));
}

Expr extensionCall(String name, List<Expr> args) {
  return ExprExtensionCall(fn: name, args: args);
}

Policy permit() {
  return const Policy.permit();
}

Policy forbid() {
  return const Policy.forbid();
}
