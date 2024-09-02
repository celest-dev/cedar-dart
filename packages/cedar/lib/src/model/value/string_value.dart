part of '../value.dart';

final class StringValue extends Value {
  const StringValue(this.value);

  factory StringValue.fromJson(String json) {
    return StringValue(json);
  }

  final String value;

  @override
  String toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StringValue && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
