part of '../value.dart';

final class BoolValue extends Value {
  const BoolValue(this.value);

  factory BoolValue.fromJson(bool json) {
    return BoolValue(json);
  }

  factory BoolValue.fromProto(pb.BoolValue boolValue) {
    return BoolValue(boolValue.value);
  }

  final bool value;

  operator ~() => BoolValue(!value);
  operator &(BoolValue other) => BoolValue(value && other.value);
  operator |(BoolValue other) => BoolValue(value || other.value);
  operator ^(BoolValue other) => BoolValue(value ^ other.value);

  @override
  bool toJson() => value;

  @override
  pb.Value toProto() => pb.Value(bool_3: pb.BoolValue(value: value));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BoolValue && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
