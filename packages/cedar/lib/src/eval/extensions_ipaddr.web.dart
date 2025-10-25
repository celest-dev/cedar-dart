({List<int> bytes, int prefixLength, bool isIpv4}) parseIpLiteral(
  String literal,
) {
  final trimmed = literal.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(literal, 'literal', 'IP literal cannot be empty');
  }

  if (_containsEmbeddedIpv4Notation(trimmed)) {
    throw ArgumentError.value(
      literal,
      'literal',
      'IPv4 addresses embedded in IPv6 are not supported',
    );
  }

  final slashIndex = trimmed.indexOf('/');
  final addressPart = slashIndex == -1
      ? trimmed
      : trimmed.substring(0, slashIndex);
  final prefixPartRaw = slashIndex == -1
      ? null
      : trimmed.substring(slashIndex + 1);
  final prefixPart = prefixPartRaw?.trim();

  late final bool isIpv4;
  late final List<int> rawBytes;

  if (_looksLikeIpv6(addressPart)) {
    rawBytes = _parseIpv6(addressPart);
    isIpv4 = false;
  } else if (_looksLikeIpv4(addressPart)) {
    rawBytes = _parseIpv4(addressPart);
    isIpv4 = true;
  } else {
    throw ArgumentError.value(literal, 'literal', 'Invalid IP address');
  }

  final bitLength = rawBytes.length * 8;
  final prefixLength = prefixPart == null
      ? bitLength
      : _parsePrefix(
          literal: literal,
          prefix: prefixPart,
          maxPrefix: bitLength,
          isIpv4: isIpv4,
        );

  if (prefixLength > bitLength) {
    throw ArgumentError.value(literal, 'literal', 'CIDR prefix out of range');
  }

  return (bytes: rawBytes, prefixLength: prefixLength, isIpv4: isIpv4);
}

bool _looksLikeIpv6(String value) {
  return value.contains(':');
}

bool _looksLikeIpv4(String value) {
  return value.contains('.');
}

bool _containsEmbeddedIpv4Notation(String value) {
  return _containsAtLeast(value, ':', 2) && _containsAtLeast(value, '.', 2);
}

bool _containsAtLeast(String value, String char, int threshold) {
  var count = 0;
  final codeUnit = char.codeUnitAt(0);
  for (var i = 0; i < value.length; i++) {
    if (value.codeUnitAt(i) == codeUnit) {
      count++;
      if (count >= threshold) {
        return true;
      }
    }
  }
  return false;
}

List<int> _parseIpv4(String input) {
  final parts = input.split('.');
  if (parts.length != 4) {
    throw ArgumentError.value(input, 'input', 'Invalid IPv4 address');
  }
  final bytes = <int>[];
  for (final part in parts) {
    if (part.isEmpty) {
      throw ArgumentError.value(input, 'input', 'Invalid IPv4 address');
    }
    final value = int.tryParse(part);
    if (value == null || value < 0 || value > 255) {
      throw ArgumentError.value(input, 'input', 'Invalid IPv4 address');
    }
    bytes.add(value);
  }
  return bytes;
}

List<int> _parseIpv6(String input) {
  if (input.isEmpty) {
    throw ArgumentError.value(input, 'input', 'Invalid IPv6 address');
  }

  if (input == '::') {
    return List<int>.filled(16, 0);
  }

  final doubleColonIndex = input.indexOf('::');
  List<int> headSegments = const <int>[];
  List<int> tailSegments = const <int>[];

  if (doubleColonIndex >= 0) {
    final headPart = input.substring(0, doubleColonIndex);
    final tailPart = input.substring(doubleColonIndex + 2);
    headSegments = _parseIpv6Section(headPart);
    tailSegments = _parseIpv6Section(tailPart);

    final requiredZeros = 8 - (headSegments.length + tailSegments.length);
    if (requiredZeros <= 0) {
      throw ArgumentError.value(input, 'input', 'Invalid IPv6 address');
    }
    return _segmentsToBytes(<int>[
      ...headSegments,
      ...List<int>.filled(requiredZeros, 0),
      ...tailSegments,
    ]);
  }

  final segments = _parseIpv6Section(input);
  if (segments.length != 8) {
    throw ArgumentError.value(input, 'input', 'Invalid IPv6 address');
  }
  return _segmentsToBytes(segments);
}

List<int> _parseIpv6Section(String part) {
  if (part.isEmpty) {
    return const [];
  }
  final pieces = part.split(':');
  final segments = <int>[];
  for (var i = 0; i < pieces.length; i++) {
    final piece = pieces[i];
    if (piece.isEmpty) {
      throw ArgumentError.value(part, 'part', 'Invalid IPv6 address');
    }
    if (piece.contains('.')) {
      throw ArgumentError.value(part, 'part', 'Invalid IPv6 segment');
    }
    final value = int.tryParse(piece, radix: 16);
    if (value == null || value < 0 || value > 0xFFFF) {
      throw ArgumentError.value(part, 'part', 'Invalid IPv6 segment');
    }
    segments.add(value);
  }
  if (segments.length > 8) {
    throw ArgumentError.value(part, 'part', 'Invalid IPv6 address');
  }
  return segments;
}

List<int> _segmentsToBytes(List<int> segments) {
  final bytes = <int>[];
  for (final segment in segments) {
    bytes.add((segment >> 8) & 0xFF);
    bytes.add(segment & 0xFF);
  }
  return bytes;
}

int _parsePrefix({
  required String literal,
  required String prefix,
  required int maxPrefix,
  required bool isIpv4,
}) {
  if (prefix.isEmpty) {
    throw ArgumentError.value(literal, 'literal', 'Invalid CIDR prefix length');
  }

  final trimmed = prefix;
  if (trimmed.length > (isIpv4 ? 2 : 3)) {
    throw ArgumentError.value(literal, 'literal', 'Invalid CIDR prefix length');
  }

  if (!_isAllDigits(trimmed) ||
      (trimmed.length > 1 && trimmed.startsWith('0'))) {
    throw ArgumentError.value(literal, 'literal', 'Invalid CIDR prefix length');
  }

  final parsed = int.parse(trimmed);
  if (parsed < 0 || parsed > maxPrefix) {
    throw ArgumentError.value(literal, 'literal', 'CIDR prefix out of range');
  }
  return parsed;
}

bool _isAllDigits(String value) {
  for (var i = 0; i < value.length; i++) {
    final code = value.codeUnitAt(i);
    if (code < 0x30 || code > 0x39) {
      return false;
    }
  }
  return true;
}
