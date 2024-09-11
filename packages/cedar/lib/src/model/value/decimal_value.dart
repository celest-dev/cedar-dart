part of '../value.dart';

final class DecimalValue extends Value {
  DecimalValue(this.value);

  factory DecimalValue.fromJson(String json) {
    return DecimalValue(Decimal.parse(json));
  }

  factory DecimalValue.fromProto(pb.DecimalValue decimalValue) {
    return DecimalValue(Decimal.parse(decimalValue.value));
  }

  final Decimal value;

  @override
  Object? toJson() => value.toString();

  @override
  pb.Value toProto() => pb.Value(
        decimal: pb.DecimalValue(value: value.toString()),
      );

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
