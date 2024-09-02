part of '../value.dart';

final class LongValue extends Value {
  const LongValue(this.value);
  factory LongValue.fromInt(int value) => LongValue(Int64(value));

  static LongValue? tryParse(String value) {
    try {
      return LongValue(Int64.parseInt(value));
    } on FormatException {
      return null;
    }
  }

  factory LongValue.fromJson(Object json) {
    return LongValue(
      json is int ? Int64(json) : Int64.parseInt(json as String),
    );
  }

  final Int64 value;

  @override
  int toJson() => value.toInt();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LongValue && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
