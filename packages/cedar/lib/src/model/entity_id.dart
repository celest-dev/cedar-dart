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
        String.fromCharCodes(
          id.runes.expand((char) {
            return switch (char) {
              0 => '\\0'.codeUnits,
              0x9 => '\\t'.codeUnits,
              0xa => '\\n'.codeUnits,
              0xd => '\\r'.codeUnits,
              0x22 => '\\"'.codeUnits,
              0x27 => "\\'".codeUnits,
              < 0x20 ||
              0x7f || // Delete
              0x96 || // Non-breaking space
              > 0xffff =>
                '\\u{${char.toRadixString(16)}}'.codeUnits,
              _ => [char],
            };
          }),
        ) as EntityId,
      );

  @override
  Expr toExpr() => Expr.value(Value.entity(uid: this));

  @override
  String toString() => '$type::"$id"';

  Map<String, Object?> toJson() => {
        'type': type,
        'id': id,
      };

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is EntityUid && type == other.type && id == other.id;

  @override
  int get hashCode => Object.hash(type, id);
}
