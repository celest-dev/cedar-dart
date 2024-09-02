import 'dart:io' show InternetAddress, InternetAddressType;

import 'package:cedar/ast.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:cedar/src/eval/extensions.dart';

final class CedarFunctionIp implements CedarFunction {
  const CedarFunctionIp();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => false;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final literal = args[0].accept(evaluator).expectString();
    final ip = InternetAddress.tryParse(literal.value);
    if (ip == null) {
      throw ArgumentError.value(literal.value, 'literal', 'Invalid IP address');
    }
    return StringValue(ip.toString());
  }
}

final class CedarFunctionIsIpv4 implements CedarFunction {
  const CedarFunctionIsIpv4();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final literal = args[0].accept(evaluator).expectString();
    final ip = InternetAddress.tryParse(literal.value);
    return BoolValue(ip != null && ip.type == InternetAddressType.IPv4);
  }
}

final class CedarFunctionIsIpv6 implements CedarFunction {
  const CedarFunctionIsIpv6();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final literal = args[0].accept(evaluator).expectString();
    final ip = InternetAddress.tryParse(literal.value);
    return BoolValue(ip != null && ip.type == InternetAddressType.IPv6);
  }
}

final class CedarFunctionIsLoopback implements CedarFunction {
  const CedarFunctionIsLoopback();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final literal = args[0].accept(evaluator).expectString();
    final ip = InternetAddress.tryParse(literal.value);
    return BoolValue(ip != null && ip.isLoopback);
  }
}

final class CedarFunctionIsMulticast implements CedarFunction {
  const CedarFunctionIsMulticast();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final literal = args[0].accept(evaluator).expectString();
    final ip = InternetAddress.tryParse(literal.value);
    return BoolValue(ip != null && ip.isMulticast);
  }
}

final class CedarFunctionIsInRange implements CedarFunction {
  const CedarFunctionIsInRange();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    throw UnimplementedError('isInRange not implemented');
  }
}
