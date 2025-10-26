import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:cedar/src/util/ip_parsing.dart';

abstract interface class CedarFunction {
  int get numArgs;
  bool get isMethod;

  Value evaluate(Evalutator evaluator, List<Expr> args);
}

const Map<String, CedarFunction> extensions = {
  'ip': CedarFunctionIp(),
  'decimal': CedarFunctionDecimal(),
  'datetime': CedarFunctionDatetime(),
  'duration': CedarFunctionDuration(),
  'offset': CedarFunctionOffset(),
  'durationSince': CedarFunctionDurationSince(),
  'toDate': CedarFunctionToDate(),
  'toTime': CedarFunctionToTime(),
  'toMilliseconds': CedarFunctionToMilliseconds(),
  'toSeconds': CedarFunctionToSeconds(),
  'toMinutes': CedarFunctionToMinutes(),
  'toHours': CedarFunctionToHours(),
  'toDays': CedarFunctionToDays(),
  'lessThan': CedarFunctionLessThan(),
  'lessThanOrEqual': CedarFunctionLessThanOrEqual(),
  'greaterThan': CedarFunctionGreaterThan(),
  'greaterThanOrEqual': CedarFunctionGreaterThanOrEqual(),
  'isIpv4': CedarFunctionIsIpv4(),
  'isIpv6': CedarFunctionIsIpv6(),
  'isLoopback': CedarFunctionIsLoopback(),
  'isMulticast': CedarFunctionIsMulticast(),
  'isInRange': CedarFunctionIsInRange(),
  'isEmpty': CedarFunctionIsEmpty(),
};

final class CedarFunctionDecimal implements CedarFunction {
  const CedarFunctionDecimal();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => false;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final literal = args[0].accept(evaluator).expectString();
    try {
      return DecimalValue.parse(literal.value);
    } on ArgumentError catch (error) {
      throw TypeException(error.message ?? error.toString());
    }
  }
}

final class CedarFunctionDatetime implements CedarFunction {
  const CedarFunctionDatetime();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => false;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final literal = args[0].accept(evaluator).expectString();
    try {
      return DatetimeValue.parse(literal.value);
    } on ArgumentError catch (error) {
      throw TypeException(error.message ?? error.toString());
    }
  }
}

final class CedarFunctionDuration implements CedarFunction {
  const CedarFunctionDuration();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => false;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final literal = args[0].accept(evaluator).expectString();
    try {
      return DurationValue.parse(literal.value);
    } on ArgumentError catch (error) {
      throw TypeException(error.message ?? error.toString());
    }
  }
}

final class CedarFunctionOffset implements CedarFunction {
  const CedarFunctionOffset();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final datetime = args[0].accept(evaluator).expectDatetime();
    final duration = args[1].accept(evaluator).expectDuration();
    try {
      return datetime.offset(duration);
    } on ArgumentError catch (error) {
      throw OverflowException(error.message ?? error.toString());
    }
  }
}

final class CedarFunctionDurationSince implements CedarFunction {
  const CedarFunctionDurationSince();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final lhs = args[0].accept(evaluator).expectDatetime();
    final rhs = args[1].accept(evaluator).expectDatetime();
    try {
      return lhs.durationSince(rhs);
    } on ArgumentError catch (error) {
      throw OverflowException(error.message ?? error.toString());
    }
  }
}

final class CedarFunctionToDate implements CedarFunction {
  const CedarFunctionToDate();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final datetime = args[0].accept(evaluator).expectDatetime();
    return datetime.toDate();
  }
}

final class CedarFunctionToTime implements CedarFunction {
  const CedarFunctionToTime();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final datetime = args[0].accept(evaluator).expectDatetime();
    return datetime.toTime();
  }
}

final class CedarFunctionToMilliseconds implements CedarFunction {
  const CedarFunctionToMilliseconds();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final duration = args[0].accept(evaluator).expectDuration();
    return Value.long(duration.toMilliseconds());
  }
}

final class CedarFunctionToSeconds implements CedarFunction {
  const CedarFunctionToSeconds();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final duration = args[0].accept(evaluator).expectDuration();
    return Value.long(duration.toSeconds());
  }
}

final class CedarFunctionToMinutes implements CedarFunction {
  const CedarFunctionToMinutes();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final duration = args[0].accept(evaluator).expectDuration();
    return Value.long(duration.toMinutes());
  }
}

final class CedarFunctionToHours implements CedarFunction {
  const CedarFunctionToHours();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final duration = args[0].accept(evaluator).expectDuration();
    return Value.long(duration.toHours());
  }
}

final class CedarFunctionToDays implements CedarFunction {
  const CedarFunctionToDays();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final duration = args[0].accept(evaluator).expectDuration();
    return Value.long(duration.toDays());
  }
}

final class CedarFunctionIp implements CedarFunction {
  const CedarFunctionIp();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => false;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final literal = args[0].accept(evaluator).expectString();
    if (literal.value.codeUnits.any((codeUnit) => codeUnit == 0)) {
      throw const TypeException('IP literal cannot contain null bytes');
    }
    try {
      final parsed = ParsedIp.parse(literal.value);
      return StringValue(
        parsed.toCanonicalString(),
        extensionJson: {
          '__extn': {'fn': 'ip', 'arg': literal.value},
        },
      );
    } on ArgumentError catch (error) {
      throw TypeException(error.message ?? error.toString());
    }
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
    try {
      final ip = ParsedIp.parse(literal.value, allowIpv4MappedDotted: true);
      return Value.bool(ip.isIpv4);
    } on ArgumentError catch (error) {
      throw TypeException(error.message ?? error.toString());
    }
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
    try {
      final ip = ParsedIp.parse(literal.value, allowIpv4MappedDotted: true);
      return Value.bool(ip.isIpv6);
    } on ArgumentError catch (error) {
      throw TypeException(error.message ?? error.toString());
    }
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
    try {
      final ip = ParsedIp.parse(literal.value, allowIpv4MappedDotted: true);
      return Value.bool(ip.isLoopback);
    } on ArgumentError catch (error) {
      throw TypeException(error.message ?? error.toString());
    }
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
    try {
      final ip = ParsedIp.parse(literal.value, allowIpv4MappedDotted: true);
      return Value.bool(ip.isMulticast);
    } on ArgumentError catch (error) {
      throw TypeException(error.message ?? error.toString());
    }
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
    final base = args[0].accept(evaluator).expectString();
    final range = args[1].accept(evaluator).expectString();
    try {
      final baseIp = ParsedIp.parse(base.value, allowIpv4MappedDotted: true);
      final rangeIp = ParsedIp.parse(range.value, allowIpv4MappedDotted: true);
      return Value.bool(rangeIp.contains(baseIp));
    } on ArgumentError catch (error) {
      throw TypeException(error.message ?? error.toString());
    }
  }
}

final class CedarFunctionLessThan implements CedarFunction {
  const CedarFunctionLessThan();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final left = args[0].accept(evaluator).expectDecimal();
    final right = args[1].accept(evaluator).expectDecimal();
    return Value.bool(left.value < right.value);
  }
}

final class CedarFunctionLessThanOrEqual implements CedarFunction {
  const CedarFunctionLessThanOrEqual();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final left = args[0].accept(evaluator).expectDecimal();
    final right = args[1].accept(evaluator).expectDecimal();
    return Value.bool(left.value <= right.value);
  }
}

final class CedarFunctionGreaterThan implements CedarFunction {
  const CedarFunctionGreaterThan();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final left = args[0].accept(evaluator).expectDecimal();
    final right = args[1].accept(evaluator).expectDecimal();
    return Value.bool(left.value > right.value);
  }
}

final class CedarFunctionGreaterThanOrEqual implements CedarFunction {
  const CedarFunctionGreaterThanOrEqual();

  @override
  int get numArgs => 2;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final left = args[0].accept(evaluator).expectDecimal();
    final right = args[1].accept(evaluator).expectDecimal();
    return Value.bool(left.value >= right.value);
  }
}

final class CedarFunctionIsEmpty implements CedarFunction {
  const CedarFunctionIsEmpty();

  @override
  int get numArgs => 1;

  @override
  bool get isMethod => true;

  @override
  Value evaluate(Evalutator evaluator, List<Expr> args) {
    final value = args[0].accept(evaluator);
    return switch (value) {
      SetValue(elements: final elements) => Value.bool(elements.isEmpty),
      RecordValue(attributes: final attributes) => Value.bool(
        attributes.isEmpty,
      ),
      StringValue(value: final string) => Value.bool(string.isEmpty),
      _ => throw TypeException('Expected set, record, or string, got $value'),
    };
  }
}
