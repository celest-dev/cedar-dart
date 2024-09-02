part of '../value.dart';

final class RecordValue extends Value {
  const RecordValue(this.attributes);

  factory RecordValue.fromJson(Map<String, Object?> json) {
    return RecordValue({
      for (final entry in json.entries) entry.key: Value.fromJson(entry.value)
    });
  }

  final Map<String, Value> attributes;

  @override
  Map<String, Object?> toJson() => {
        for (final entry in attributes.entries) entry.key: entry.value.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordValue &&
          const MapEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => const MapEquality().hash(attributes);
}
