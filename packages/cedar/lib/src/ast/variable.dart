import 'package:cedar/src/ast.dart';

CedarExprVariable principal() {
  return CedarExprVariable(CedarVariable.principal);
}

CedarExprVariable action() {
  return CedarExprVariable(CedarVariable.action);
}

CedarExprVariable resource() {
  return CedarExprVariable(CedarVariable.resource);
}

CedarExprVariable context() {
  return CedarExprVariable(CedarVariable.context);
}
