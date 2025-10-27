part of 'value.dart';

/// Represents an entity type name. Consists of a namespace and the type name.
extension type const EntityTypeName(String _type) implements String {}

/// Identifier portion of the [EntityUid] type.
///
/// All strings are valid [EntityId]s, and can be constructed either using
/// [EntityId.new] or by casting a [String] to [EntityId].
extension type const EntityId(String _id) implements String {}

/// Unique ID for an entity, such as `User::"alice"`.
final class EntityUid implements Component {
  const EntityUid(this.type, this.id);
  const EntityUid.of(String type, String id)
    : type = type as EntityTypeName,
      id = id as EntityId;

  factory EntityUid.fromJson(Map<String, Object?> json) {
    switch (json) {
      case {'type': final String type, 'id': final String id} ||
          {'__entity': {'type': final String type, 'id': final String id}}:
        return EntityUid(EntityTypeName(type), EntityId(id));
      default:
        throw FormatException('Invalid entity ID JSON: $json');
    }
  }

  factory EntityUid.fromProto(pb.EntityUid entityUid) {
    return EntityUid(EntityTypeName(entityUid.type), EntityId(entityUid.id));
  }

  factory EntityUid.parse(String uid) {
    final parts = uid.split('::');
    if (parts.length < 2) {
      throw FormatException('Invalid entity ID: $uid');
    }
    final idPart = parts.last;
    if (idPart.isEmpty ||
        idPart[0] != '"' ||
        idPart[idPart.length - 1] != '"') {
      throw FormatException('Invalid entity ID: $uid');
    }
    return EntityUid(
      EntityTypeName(parts.sublist(0, parts.length - 1).join('::')),
      EntityId(idPart.substring(1, idPart.length - 1)),
    );
  }

  const EntityUid.unknown()
    : type = const EntityTypeName(''),
      id = const EntityId('');

  final EntityTypeName type;
  final EntityId id;

  /// Returns a normalized version of this entity ID.
  ///
  /// Cedar prohibits whitespace in entity IDs, so this method removes all
  /// whitespace from the [type] and [id].
  ///
  /// See Cedar [RFC 9](https://github.com/cedar-policy/rfcs/blob/main/text/0009-disallow-whitespace-in-entityuid.md)
  /// for more information.
  EntityUid get normalized => EntityUid(
    type,
    EntityId(
      (StringBuffer()..writeAll(id.runes.map(_normalizeEntityIdRune)))
          .toString(),
    ),
  );

  @override
  Expr toExpr() => Expr.value(Value.entity(uid: this));

  pb.EntityUid toProto() => pb.EntityUid(type: type, id: id);

  @override
  String toString() => '$type::"$id"';

  Map<String, Object?> toJson() => {'type': type, 'id': id};

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is EntityUid && type == other.type && id == other.id ||
      other is EntityValue && this == other.uid;

  @override
  int get hashCode => Object.hash(type, id);
}

String _normalizeEntityIdRune(int rune) {
  switch (rune) {
    case 0:
      return r'\0';
    case 0x9:
      return r'\t';
    case 0xa:
      return r'\n';
    case 0xd:
      return r'\r';
    case 0x22:
      return r'\"';
    case 0x27:
      return r"\'";
    case 0x5c:
      return r'\\';
    default:
      return _isPrintableEntityRune(rune)
          ? String.fromCharCode(rune)
          : '\\u{${rune.toRadixString(16)}}';
  }
}

bool _isPrintableEntityRune(int rune) {
  if (rune < 0x20 || rune == 0x7f) {
    return false;
  }
  final scalar = String.fromCharCode(rune);
  if (_entityOtherCategory.hasMatch(scalar)) {
    return false;
  }
  if (_entityMarkCategory.hasMatch(scalar)) {
    return false;
  }
  if (_entitySeparatorCategory.hasMatch(scalar)) {
    return rune == 0x20;
  }
  return true;
}

final RegExp _entityOtherCategory = RegExp(r'^\p{C}$', unicode: true);
final RegExp _entityMarkCategory = RegExp(r'^\p{M}$', unicode: true);
final RegExp _entitySeparatorCategory = RegExp(r'^\p{Z}$', unicode: true);
