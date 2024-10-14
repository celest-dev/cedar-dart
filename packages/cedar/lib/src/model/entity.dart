part of 'value.dart';

/// Dart representation of a Cedar [entity](https://docs.cedarpolicy.com/policies/syntax-entity.html).
///
/// Conforms to the entity [JSON format](https://docs.cedarpolicy.com/auth/entities-syntax.html#entities).
final class Entity implements Component {
  const Entity({
    required this.uid,
    this.parents = const [],
    this.attributes = const {},
  });

  factory Entity.fromJson(Map<String, Object?> json) => Entity(
        uid: EntityUid.fromJson(json['uid'] as Map<String, Object?>),
        parents: (json['parents'] as List<Object?>)
            .map((e) => EntityUid.fromJson(e as Map<String, Object?>))
            .toList(),
        attributes: (json['attrs'] as Map<Object?, Object?>)
            .cast<String, Object?>()
            .map((key, value) => MapEntry(key, Value.fromJson(value))),
      );

  factory Entity.fromProto(pb.Entity proto) {
    return Entity(
      uid: EntityUid.fromProto(proto.uid),
      parents: proto.parents.map((e) => EntityUid.fromProto(e)).toList(),
      attributes: proto.attributes.map(
        (key, value) => MapEntry(key, Value.fromProto(value)),
      ),
    );
  }

  final EntityUid uid;
  final List<EntityUid> parents;
  final Map<String, Value> attributes;

  Map<String, Object?> toJson() => {
        'uid': uid.toJson(),
        'parents': parents.map((e) => e.toJson()).toList(),
        'attrs': attributes.map((key, value) => MapEntry(key, value.toJson())),
      };

  pb.Entity toProto() {
    return pb.Entity(
      uid: uid.toProto(),
      parents: parents.map((e) => e.toProto()).toList(),
      attributes:
          attributes.map((key, value) => MapEntry(key, value.toProto())),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity &&
          uid == other.uid &&
          const ListEquality().equals(parents, other.parents) &&
          const MapEquality().equals(attributes, other.attributes);

  @override
  int get hashCode => Object.hashAll([
        uid,
        ...parents,
        ...attributes.entries,
      ]);

  @override
  String toString() =>
      'Entity(uid: $uid, parents: $parents, attributes: $attributes)';

  @override
  Expr toExpr() => uid.toExpr();
}
