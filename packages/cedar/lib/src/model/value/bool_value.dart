part of '../value.dart';

final class BoolValue extends Value {
  const BoolValue(this.value);

  factory BoolValue.fromJson(bool json) {
    return BoolValue(json);
  }

  final bool value;

  operator ~() => BoolValue(!value);
  operator &(BoolValue other) => BoolValue(value && other.value);
  operator |(BoolValue other) => BoolValue(value || other.value);
  operator ^(BoolValue other) => BoolValue(value ^ other.value);

  @override
  bool toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BoolValue && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
