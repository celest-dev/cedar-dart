import 'package:cedar/cedar.dart';
import 'package:cedar/src/ast.dart';

CedarExpr boolean(bool value) {
  return CedarExprValue(CedarValue.bool(value));
}

CedarExpr true_() {
  return boolean(true);
}

CedarExpr false_() {
  return boolean(false);
}

CedarExpr string(String value) {
  return CedarExprValue(CedarValue.string(value));
}

CedarExpr long(int value) {
  return CedarExprValue(CedarValue.long(value));
}

CedarExpr set(Iterable<CedarExpr> value) {
  return CedarExprSet(value.toList());
}

typedef Pair = (String key, CedarExpr value);

CedarExpr record(Iterable<Pair> pairs) {
  return CedarExprRecord({
    for (final (key, value) in pairs) key: value,
  });
}

CedarExpr entityUid(String type, String id) {
  return CedarExprValue(CedarValue.entity(entityId: CedarEntityId(type, id)));
}

CedarExpr extensionCall(String name, List<CedarExpr> args) {
  return CedarExprFunctionCall(fn: name, args: args);
}

CedarPolicy permit() {
  return const CedarPolicy.permit();
}

CedarPolicy forbid() {
  return const CedarPolicy.forbid();
}
