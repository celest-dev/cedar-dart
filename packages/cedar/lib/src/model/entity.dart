part of 'value.dart';

/// Dart representation of a Cedar [entity](https://docs.cedarpolicy.com/policies/syntax-entity.html).
///
/// Conforms to the entity [JSON format](https://docs.cedarpolicy.com/auth/entities-syntax.html#entities).
final class Entity implements Component {
  const Entity({
    required this.uid,
    this.parents = const [],
    this.attributes = const {},
    this.tags = const {},
  });

  factory Entity.fromJson(Map<String, Object?> json) => Entity(
    uid: EntityUid.fromJson(json['uid'] as Map<String, Object?>),
    parents: (json['parents'] as List<Object?>)
        .map((e) => EntityUid.fromJson(e as Map<String, Object?>))
        .toList(),
    attributes: (json['attrs'] as Map<Object?, Object?>)
        .cast<String, Object?>()
        .map((key, value) => MapEntry(key, Value.fromJson(value))),
    tags:
        (json['tags'] as Map<Object?, Object?>?)?.cast<String, Object?>().map(
          (key, value) => MapEntry(key, Value.fromJson(value)),
        ) ??
        const {},
  );

  factory Entity.fromProto(pb.Entity proto) {
    return Entity(
      uid: EntityUid.fromProto(proto.uid),
      parents: proto.parents.map((e) => EntityUid.fromProto(e)).toList(),
      attributes: proto.attributes.map(
        (key, value) => MapEntry(key, Value.fromProto(value)),
      ),
      tags: proto.tags.map(
        (key, value) => MapEntry(key, Value.fromProto(value)),
      ),
    );
  }

  final EntityUid uid;
  final List<EntityUid> parents;
  final Map<String, Value> attributes;
  final Map<String, Value> tags;

  Map<String, Object?> toJson({bool normalizedUids = false}) {
    Object? serializeValue(Value value) {
      final json = value.toJson();
      return normalizedUids ? _normalizeEntityJson(json) : json;
    }

    final attrsJson = attributes.map(
      (key, value) => MapEntry(key, serializeValue(value)),
    );

    final entityJson = <String, Object?>{
      'uid': normalizedUids ? uid.normalized.toJson() : uid.toJson(),
      'parents': parents
          .map(
            (parent) =>
                normalizedUids ? parent.normalized.toJson() : parent.toJson(),
          )
          .toList(),
      'attrs': attrsJson,
    };

    if (tags.isNotEmpty) {
      entityJson['tags'] = tags.map(
        (key, value) => MapEntry(key, serializeValue(value)),
      );
    }

    return entityJson;
  }

  pb.Entity toProto() {
    return pb.Entity(
      uid: uid.toProto(),
      parents: parents.map((e) => e.toProto()).toList(),
      attributes: attributes.entries.map(
        (entry) => MapEntry(entry.key, entry.value.toProto()),
      ),
      tags: tags.entries.map(
        (entry) => MapEntry(entry.key, entry.value.toProto()),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity &&
          uid == other.uid &&
          const ListEquality<EntityUid>().equals(parents, other.parents) &&
          const MapEquality<String, Value>().equals(
            attributes,
            other.attributes,
          ) &&
          const MapEquality<String, Value>().equals(tags, other.tags);

  @override
  int get hashCode => const DeepCollectionEquality().hash([
    uid,
    parents,
    attributes.entries,
    tags.entries,
  ]);

  @override
  String toString() =>
      'Entity(uid: $uid, parents: $parents, attributes: $attributes, tags: $tags)';

  @override
  Expr toExpr() => uid.toExpr();
}

Object? _normalizeEntityJson(Object? json) {
  if (json is Map<String, Object?>) {
    if (json.length == 2) {
      final type = json['type'];
      final id = json['id'];
      if (type is String && id is String) {
        final normalized = EntityUid.of(type, id).normalized;
        return normalized.toJson();
      }
    }
    return json.map((key, value) => MapEntry(key, _normalizeEntityJson(value)));
  }
  if (json is List) {
    return [for (final element in json) _normalizeEntityJson(element)];
  }
  return json;
}
