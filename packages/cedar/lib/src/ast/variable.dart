import 'package:cedar/cedar.dart';
import 'package:cedar/src/ast.dart';

ExprVariable principal() {
  return ExprVariable(CedarVariable.principal);
}

ExprVariable action() {
  return ExprVariable(CedarVariable.action);
}

ExprVariable resource() {
  return ExprVariable(CedarVariable.resource);
}

ExprVariable context() {
  return ExprVariable(CedarVariable.context);
}
