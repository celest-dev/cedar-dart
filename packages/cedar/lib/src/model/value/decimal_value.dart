part of '../value.dart';

final class DecimalValue extends Value {
  DecimalValue(this.value);

  final Decimal value;

  @override
  String toString() {
    return value.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DecimalValue && value == other.value;

  @override
  int get hashCode => Object.hash(DecimalValue, value);

  @override
  Object? toJson() => value.toString();
}
