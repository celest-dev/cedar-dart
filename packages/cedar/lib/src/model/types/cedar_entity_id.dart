part of 'cedar_value.dart';

final class CedarEntityValue extends CedarValue {
  const CedarEntityValue({required this.entityId});

  factory CedarEntityValue.fromJson(Map<String, Object?> json) {
    switch (json) {
      case {'__entity': {'type': final String type, 'id': final String id}} ||
            {'type': final String type, 'id': final String id}:
        return CedarEntityValue(entityId: CedarEntityId(type, id));
      default:
        throw FormatException('Invalid entity value JSON: $json');
    }
  }

  final CedarEntityId entityId;

  @override
  Map<String, Object?> toJson() => {
        '__entity': entityId.toJson(),
      };

  @override
  String toString() => entityId.toString();

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is CedarEntityValue && entityId == other.entityId;

  @override
  int get hashCode => Object.hash(CedarEntityValue, entityId);
}

final class CedarEntityId implements CedarComponent {
  const CedarEntityId(this.type, this.id);

  factory CedarEntityId.fromJson(Map<String, Object?> json) {
    switch (json) {
      case {'type': final String type, 'id': final String id} ||
            {'__entity': {'type': final String type, 'id': final String id}}:
        return CedarEntityId(type, id);
      default:
        throw FormatException('Invalid entity ID JSON: $json');
    }
  }

  const CedarEntityId.unknown()
      : type = '',
        id = '';

  final String type;
  final String id;

  /// Returns a normalized version of this entity ID.
  ///
  /// Cedar prohibits whitespace in entity IDs, so this method removes all
  /// whitespace from the [type] and [id].
  ///
  /// See Cedar [RFC 9](https://github.com/cedar-policy/rfcs/blob/main/text/0009-disallow-whitespace-in-entityuid.md)
  /// for more information.
  CedarEntityId get normalized => CedarEntityId(
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
        ),
      );

  @override
  CedarExpr toExpr() => CedarExpr.value(CedarEntityValue(entityId: this));

  @override
  String toString() => '$type::"$id"';

  Map<String, Object?> toJson() => {
        'type': type,
        'id': id,
      };

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is CedarEntityId && type == other.type && id == other.id;

  @override
  int get hashCode => Object.hash(type, id);
}
