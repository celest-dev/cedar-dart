import 'package:cedar/src/eval/extensions_ipaddr.web.dart'
    if (dart.library.io) 'package:cedar/src/eval/extensions_ipaddr.io.dart'
    as ipaddr;

class ParsedIp {
  ParsedIp._(List<int> bytes, this.prefixLength, this.isIpv4)
    : _bytes = List<int>.unmodifiable(bytes);

  factory ParsedIp.parse(String literal, {bool allowIpv4MappedDotted = false}) {
    final normalized = allowIpv4MappedDotted
        ? _rewriteIpv4MappedDotted(literal)
        : literal;
    final parsed = ipaddr.parseIpLiteral(normalized);
    return ParsedIp._(parsed.bytes, parsed.prefixLength, parsed.isIpv4);
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

  bool contains(ParsedIp other) {
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
        if (!wrote) {
          buffer.write('::');
          wrote = true;
        } else if (!lastWasDoubleColon) {
          buffer.write('::');
        }
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
      buffer.write('0');
    }
    return buffer.toString();
  }
}
