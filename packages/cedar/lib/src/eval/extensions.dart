import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:decimal/decimal.dart';

import 'extensions_ipaddr.web.dart'
    if (dart.library.io) 'extensions_ipaddr.io.dart';

abstract interface class CedarFunction {
  int get numArgs;
  bool get isMethod;

  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args);
}

const Map<String, CedarFunction> extensions = {
  'ip': CedarFunctionIp(),
  'decimal': CedarFunctionDecimal(),
  'lessThan': CedarFunctionLessThan(),
  'lessThanOrEqual': CedarFunctionLessThanOrEqual(),
  'greaterThan': CedarFunctionGreaterThan(),
  'greaterThanOrEqual': CedarFunctionGreaterThanOrEqual(),
  'isIpv4': CedarFunctionIsIpv4(),
  'isIpv6': CedarFunctionIsIpv6(),
  'isLoopback': CedarFunctionIsLoopback(),
  'isMulticast': CedarFunctionIsMulticast(),
  'isInRange': CedarFunctionIsInRange(),
};

final class CedarFunctionDecimal implements CedarFunction {
  const CedarFunctionDecimal();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => false;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    final literal = args[0].accept(evaluator).expectString();
    final decimal = Decimal.parse(literal.value);
    return CedarDecimal(decimal);
  }
}

final class CedarFunctionLessThan implements CedarFunction {
  const CedarFunctionLessThan();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    final left = args[0].accept(evaluator).expectDecimal();
    final right = args[1].accept(evaluator).expectDecimal();
    return CedarBool(left.value < right.value);
  }
}

final class CedarFunctionLessThanOrEqual implements CedarFunction {
  const CedarFunctionLessThanOrEqual();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    final left = args[0].accept(evaluator).expectDecimal();
    final right = args[1].accept(evaluator).expectDecimal();
    return CedarBool(left.value <= right.value);
  }
}

final class CedarFunctionGreaterThan implements CedarFunction {
  const CedarFunctionGreaterThan();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    final left = args[0].accept(evaluator).expectDecimal();
    final right = args[1].accept(evaluator).expectDecimal();
    return CedarBool(left.value > right.value);
  }
}

final class CedarFunctionGreaterThanOrEqual implements CedarFunction {
  const CedarFunctionGreaterThanOrEqual();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  CedarValue evaluate(Evalutator evaluator, List<CedarExpr> args) {
    final left = args[0].accept(evaluator).expectDecimal();
    final right = args[1].accept(evaluator).expectDecimal();
    return CedarBool(left.value >= right.value);
  }
}
