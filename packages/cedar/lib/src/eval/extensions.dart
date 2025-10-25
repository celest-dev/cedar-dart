import 'package:cedar/ast.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:decimal/decimal.dart';

import 'extensions_ipaddr.web.dart'
    if (dart.library.io) 'extensions_ipaddr.io.dart'
    as ipaddr;

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
    final decimal = Decimal.parse(literal.value);
    return DecimalValue(decimal);
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
    return DatetimeValue.parse(literal.value);
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
    return DurationValue.parse(literal.value);
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
    return datetime.offset(duration);
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
    return lhs.durationSince(rhs);
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
    final ip = _ParsedIp.parse(literal.value);
    return StringValue(ip.toCanonicalString());
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
    final ip = _ParsedIp.parse(literal.value, allowIpv4MappedDotted: true);
    return BoolValue(ip.isIpv4);
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
    final ip = _ParsedIp.parse(literal.value, allowIpv4MappedDotted: true);
    return BoolValue(ip.isIpv6);
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
    final ip = _ParsedIp.parse(literal.value, allowIpv4MappedDotted: true);
    return BoolValue(ip.isLoopback);
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
    final ip = _ParsedIp.parse(literal.value, allowIpv4MappedDotted: true);
    return BoolValue(ip.isMulticast);
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
    final baseIp = _ParsedIp.parse(base.value, allowIpv4MappedDotted: true);
    final rangeIp = _ParsedIp.parse(range.value, allowIpv4MappedDotted: true);
    return BoolValue(rangeIp.contains(baseIp));
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
    return BoolValue(left.value < right.value);
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
    return BoolValue(left.value <= right.value);
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
    return BoolValue(left.value > right.value);
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
    return BoolValue(left.value >= right.value);
  }
}

final class _ParsedIp {
  _ParsedIp._(List<int> bytes, this.prefixLength, this.isIpv4)
    : _bytes = List<int>.unmodifiable(bytes);

  factory _ParsedIp.parse(
    String literal, {
    bool allowIpv4MappedDotted = false,
  }) {
    final normalized = allowIpv4MappedDotted
        ? _rewriteIpv4MappedDotted(literal)
        : literal;
    final parsed = ipaddr.parseIpLiteral(normalized);
    return _ParsedIp._(parsed.bytes, parsed.prefixLength, parsed.isIpv4);
  }

  final List<int> _bytes;
  final int prefixLength;
  final bool isIpv4;

  bool get isIpv6 => !isIpv4;
  int get _bitLength => _bytes.length * 8;

  String toCanonicalString() {
    if (isIpv4) {
      final address = _bytes.join('.');
      return prefixLength == _bitLength ? address : '$address/$prefixLength';
    }
    if (_isIpv4Mapped(_bytes)) {
      final a = _bytes[12];
      final b = _bytes[13];
      final c = _bytes[14];
      final d = _bytes[15];
      final address = '::ffff:$a.$b.$c.$d';
      return prefixLength == _bitLength ? address : '$address/$prefixLength';
    }
    final segments = <int>[];
    for (var i = 0; i < _bytes.length; i += 2) {
      segments.add((_bytes[i] << 8) | _bytes[i + 1]);
    }
    final address = _formatIpv6(segments);
    return prefixLength == _bitLength ? address : '$address/$prefixLength';
  }

  bool contains(_ParsedIp other) {
    if (isIpv4 != other.isIpv4) {
      return false;
    }
    if (prefixLength > other.prefixLength) {
      return false;
    }
    final maskedSelf = _maskBytes(_bytes, prefixLength);
    final maskedOther = _maskBytes(other._bytes, prefixLength);
    for (var i = 0; i < maskedSelf.length; i++) {
      if (maskedSelf[i] != maskedOther[i]) {
        return false;
      }
    }
    return true;
  }

  bool get isLoopback {
    if (isIpv4) {
      return _bytes.length == 4 && _bytes[0] == 127 && prefixLength >= 8;
    }
    if (_bytes.length != 16 || prefixLength < _bitLength) {
      return false;
    }
    for (var i = 0; i < _bytes.length - 1; i++) {
      if (_bytes[i] != 0) {
        return false;
      }
    }
    return _bytes.last == 1;
  }

  bool get isMulticast {
    if (isIpv4) {
      return _bytes.length == 4 &&
          _bytes[0] >= 224 &&
          _bytes[0] <= 239 &&
          prefixLength >= 4;
    }
    return _bytes.length == 16 && _bytes.first == 0xFF && prefixLength >= 8;
  }

  static List<int> _maskBytes(List<int> raw, int prefixLength) {
    final masked = List<int>.from(raw);
    if (prefixLength >= masked.length * 8) {
      return masked;
    }
    var remaining = prefixLength;
    for (var i = 0; i < masked.length; i++) {
      if (remaining >= 8) {
        remaining -= 8;
        continue;
      }
      if (remaining > 0) {
        final keepBits = (0xFF << (8 - remaining)) & 0xFF;
        masked[i] &= keepBits;
        remaining = 0;
      } else {
        masked[i] = 0;
      }
    }
    return masked;
  }

  static bool _isIpv4Mapped(List<int> bytes) {
    if (bytes.length != 16) {
      return false;
    }
    for (var i = 0; i < 10; i++) {
      if (bytes[i] != 0) {
        return false;
      }
    }
    return bytes[10] == 0xFF && bytes[11] == 0xFF;
  }

  static String _rewriteIpv4MappedDotted(String literal) {
    var colonCount = 0;
    var dotCount = 0;
    for (var i = 0; i < literal.length; i++) {
      final code = literal.codeUnitAt(i);
      if (code == 0x3A) {
        colonCount++;
      } else if (code == 0x2E) {
        dotCount++;
      }
    }
    if (colonCount < 2 || dotCount < 2) {
      return literal;
    }

    final slashIndex = literal.indexOf('/');
    final addressPart = slashIndex == -1
        ? literal
        : literal.substring(0, slashIndex);
    final lastColon = addressPart.lastIndexOf(':');
    if (lastColon == -1) {
      return literal;
    }
    final ipv4Part = addressPart.substring(lastColon + 1);
    final octets = ipv4Part.split('.');
    if (octets.length != 4) {
      return literal;
    }
    final bytes = <int>[];
    for (final octet in octets) {
      final value = int.tryParse(octet);
      if (value == null || value < 0 || value > 255) {
        return literal;
      }
      bytes.add(value);
    }
    final upper = ((bytes[0] << 8) | bytes[1])
        .toRadixString(16)
        .padLeft(4, '0');
    final lower = ((bytes[2] << 8) | bytes[3])
        .toRadixString(16)
        .padLeft(4, '0');
    final rebuiltAddress =
        '${addressPart.substring(0, lastColon + 1)}$upper:$lower';
    if (slashIndex == -1) {
      return rebuiltAddress;
    }
    return '$rebuiltAddress${literal.substring(slashIndex)}';
  }

  // Compresses the longest zero run to ``::`` per canonical IPv6 formatting rules.
  static String _formatIpv6(List<int> segments) {
    var bestStart = -1;
    var bestLength = 0;
    var currentStart = -1;

    for (var i = 0; i < segments.length; i++) {
      if (segments[i] == 0) {
        currentStart = currentStart == -1 ? i : currentStart;
      } else if (currentStart != -1) {
        final length = i - currentStart;
        if (length > bestLength) {
          bestStart = currentStart;
          bestLength = length;
        }
        currentStart = -1;
      }
    }

    if (currentStart != -1) {
      final length = segments.length - currentStart;
      if (length > bestLength) {
        bestStart = currentStart;
        bestLength = length;
      }
    }

    if (bestLength < 2) {
      bestStart = -1;
      bestLength = 0;
    }

    final buffer = StringBuffer();
    var wrote = false;
    var lastWasDoubleColon = false;

    for (var i = 0; i < segments.length;) {
      if (i == bestStart) {
        buffer.write('::');
        wrote = true;
        lastWasDoubleColon = true;
        i += bestLength;
        if (i >= segments.length) {
          break;
        }
        continue;
      }

      if (wrote && !lastWasDoubleColon) {
        buffer.write(':');
      }
      buffer.write(segments[i].toRadixString(16));
      wrote = true;
      lastWasDoubleColon = false;
      i++;
    }

    if (!wrote) {
      buffer.write('::');
    }

    return buffer.toString();
  }
}
