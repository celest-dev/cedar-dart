import 'package:cedar/cedar.dart';
import 'package:collection/collection.dart';

/// Dart representation of a Cedar [entity](https://docs.cedarpolicy.com/policies/syntax-entity.html).
///
/// Conforms to the entity [JSON format](https://docs.cedarpolicy.com/auth/entities-syntax.html#entities).
final class CedarEntity {
  const CedarEntity({
    required this.id,
    this.parents = const [],
    this.attributes = const {},
  });

  factory CedarEntity.fromJson(Map<String, Object?> json) => CedarEntity(
        id: CedarEntityId.fromJson(json['uid'] as Map<String, Object?>),
        parents: (json['parents'] as List<Object?>)
            .map((e) => CedarEntityId.fromJson(e as Map<String, Object?>))
            .toList(),
        attributes: (json['attrs'] as Map<Object?, Object?>)
            .cast<String, Object?>()
            .map((key, value) => MapEntry(key, CedarValue.fromJson(value))),
      );

  final CedarEntityId id;
  final List<CedarEntityId> parents;
  final Map<String, CedarValue> attributes;

  Map<String, Object?> toJson() => {
        'uid': id.toJson(),
        'parents': parents.map((e) => e.toJson()).toList(),
        'attrs': attributes.map((key, value) => MapEntry(key, value.toJson())),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarEntity &&
          id == other.id &&
          const ListEquality().equals(parents, other.parents) &&
          const MapEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hashAll([
        id,
        ...parents,
        ...attributes.entries,
      ]);
}
