part of '../value.dart';

final class RecordValue extends Value {
  const RecordValue(this.attributes);

  factory RecordValue.fromJson(Map<String, Object?> json) {
    return RecordValue({
      for (final entry in json.entries) entry.key: Value.fromJson(entry.value),
    });
  }

  factory RecordValue.fromProto(pb.RecordValue recordValue) {
    return RecordValue({
      for (final entry in recordValue.attributes.entries)
        entry.key: Value.fromProto(entry.value),
    });
  }

  final Map<String, Value> attributes;

  @override
  Map<String, Object?> toJson() => {
    for (final entry in attributes.entries) entry.key: entry.value.toJson(),
  };

  @override
  pb.Value toProto() => pb.Value(
    record: pb.RecordValue(
      attributes: attributes.entries.map(
        (entry) => MapEntry(entry.key, entry.value.toProto()),
      ),
    ),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordValue &&
          const MapEquality<String, Value>().equals(
            attributes,
            other.attributes,
          );

  @override
  int get hashCode => const MapEquality<String, Value>().hash(attributes);
}
