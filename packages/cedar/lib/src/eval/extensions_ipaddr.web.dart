import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:cedar/src/eval/extensions.dart';

final class CedarFunctionIp implements CedarFunction {
  const CedarFunctionIp();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => false;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    throw UnsupportedError('IP methods not supported on web');
  }
}

final class CedarFunctionIsIpv4 implements CedarFunction {
  const CedarFunctionIsIpv4();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    throw UnsupportedError('IP methods not supported on web');
  }
}

final class CedarFunctionIsIpv6 implements CedarFunction {
  const CedarFunctionIsIpv6();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    throw UnsupportedError('IP methods not supported on web');
  }
}

final class CedarFunctionIsLoopback implements CedarFunction {
  const CedarFunctionIsLoopback();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    throw UnsupportedError('IP methods not supported on web');
  }
}

final class CedarFunctionIsMulticast implements CedarFunction {
  const CedarFunctionIsMulticast();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    throw UnsupportedError('IP methods not supported on web');
  }
}

final class CedarFunctionIsInRange implements CedarFunction {
  const CedarFunctionIsInRange();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    throw UnsupportedError('IP methods not supported on web');
  }
}
