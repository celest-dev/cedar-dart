import 'dart:io' show InternetAddress, InternetAddressType;

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

  final parsedAddress = InternetAddress.tryParse(addressPart);
  if (parsedAddress == null) {
    throw ArgumentError.value(literal, 'literal', 'Invalid IP address');
  }

  final bytes = List<int>.from(parsedAddress.rawAddress);
  final bitLength = bytes.length * 8;
  final isIpv4 = parsedAddress.type == InternetAddressType.IPv4;
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

  return (bytes: bytes, prefixLength: prefixLength, isIpv4: isIpv4);
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
