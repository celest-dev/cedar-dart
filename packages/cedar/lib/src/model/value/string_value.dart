part of '../value.dart';

final class StringValue extends Value {
  const StringValue(this.value);

  factory StringValue.fromJson(String json) {
    return StringValue(json);
  }

  factory StringValue.fromProto(pb.StringValue stringValue) {
    return StringValue(stringValue.value);
  }

  final String value;

  @override
  String toJson() => value;

  @override
  pb.Value toProto() => pb.Value(string: pb.StringValue(value: value));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StringValue && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
