part of '../value.dart';

final class DecimalValue extends Value {
  DecimalValue(this.value, {this.literal});

  factory DecimalValue.fromJson(String json) {
    return DecimalValue.parse(json);
  }

  factory DecimalValue.fromProto(pb.DecimalValue decimalValue) {
    return DecimalValue.parse(decimalValue.value);
  }

  factory DecimalValue.parse(String literal) {
    return DecimalValue(_parseDecimal(literal), literal: literal);
  }

  final Decimal value;
  final String? literal;

  @override
  Object? toJson() => {
    '__extn': {'fn': 'decimal', 'arg': literal ?? value.toString()},
  };

  @override
  pb.Value toProto() =>
      pb.Value(decimal: pb.DecimalValue(value: literal ?? value.toString()));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DecimalValue && value == other.value;

  @override
  int get hashCode => Object.hash(DecimalValue, value);

  @override
  String toString() {
    return value.toString();
  }
}

Decimal _parseDecimal(String literal) {
  if (literal.isEmpty) {
    _decimalError('empty string');
  }

  if (literal.startsWith('+')) {
    _decimalError('invalid decimal literal');
  }

  final bool isNegative = literal.startsWith('-');
  final int startIndex = isNegative ? 1 : 0;
  final int dotIndex = literal.indexOf('.', startIndex);
  if (dotIndex == -1) {
    _decimalError('missing decimal point');
  }

  final String integerPart = literal.substring(startIndex, dotIndex);
  final String fractionalPart = literal.substring(dotIndex + 1);
  if (integerPart.isEmpty || fractionalPart.isEmpty) {
    _decimalError('invalid decimal literal');
  }
  if (!_decimalDigits.hasMatch(integerPart) ||
      !_decimalDigits.hasMatch(fractionalPart)) {
    _decimalError('invalid decimal literal');
  }
  if (fractionalPart.length > _kDecimalScale) {
    _decimalError('too many digits after decimal point');
  }

  final BigInt integerValue = BigInt.parse(integerPart);
  final BigInt fractionValue = BigInt.parse(fractionalPart);
  final int scaleDiff = _kDecimalScale - fractionalPart.length;
  final BigInt scaledFraction = fractionValue * BigInt.from(10).pow(scaleDiff);
  BigInt scaled = integerValue * _kDecimalScaleFactor + scaledFraction;
  if (isNegative) {
    scaled = -scaled;
  }

  if (scaled < _kMinDecimalScaled || scaled > _kMaxDecimalScaled) {
    _decimalError('overflow');
  }

  return Decimal.parse(literal);
}

Never _decimalError(String message) {
  throw ArgumentError('error parsing decimal value: $message');
}

const int _kDecimalScale = 4;
final BigInt _kDecimalScaleFactor = BigInt.from(10).pow(_kDecimalScale);
final BigInt _kMaxDecimalScaled = BigInt.from(9223372036854775807);
final BigInt _kMinDecimalScaled = BigInt.from(-9223372036854775808);
final RegExp _decimalDigits = RegExp(r'^\d+$');
