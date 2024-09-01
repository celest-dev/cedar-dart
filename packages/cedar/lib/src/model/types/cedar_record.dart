part of 'cedar_value.dart';

@Deprecated('Use CedarRecord instead')
typedef CedarValueRecord = CedarRecord;

final class CedarRecord extends CedarValue {
  const CedarRecord(this.attributes);

  factory CedarRecord.fromJson(Map<String, Object?> json) {
    return CedarRecord({
      for (final entry in json.entries)
        entry.key: CedarValue.fromJson(entry.value)
    });
  }

  final Map<String, CedarValue> attributes;

  @override
  Map<String, Object?> toJson() => {
        for (final entry in attributes.entries) entry.key: entry.value.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarRecord &&
          const MapEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => const MapEquality().hash(attributes);
}
