part of '../value.dart';

final class EntityValue extends Value implements Component {
  const EntityValue({required this.uid}) : _json = null;

  const EntityValue._({required this.uid, required Map<String, Object?> json})
    : _json = json;

  factory EntityValue.fromJson(Map<String, Object?> json) {
    switch (json) {
      case {'__entity': {'type': final String type, 'id': final String id}}:
        return EntityValue._(
          uid: EntityUid.of(type, id),
          json: Map.unmodifiable({
            '__entity': Map.unmodifiable({'type': type, 'id': id}),
          }),
        );
      case {'type': final String type, 'id': final String id}:
        return EntityValue._(
          uid: EntityUid.of(type, id),
          json: Map.unmodifiable({'type': type, 'id': id}),
        );
      default:
        throw FormatException('Invalid entity value JSON: $json');
    }
  }

  factory EntityValue.fromProto(pb.EntityValue entityValue) {
    return EntityValue(uid: EntityUid.fromProto(entityValue.uid));
  }

  final EntityUid uid;
  final Map<String, Object?>? _json;

  @override
  Expr toExpr() => Expr.value(this);

  @override
  Map<String, Object?> toJson() => _json ?? {'__entity': uid.toJson()};

  @override
  pb.Value toProto() => pb.Value(entity: pb.EntityValue(uid: uid.toProto()));

  @override
  String toString() => uid.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityValue && uid == other.uid ||
      other is EntityUid && uid == other;

  @override
  int get hashCode => Object.hash(EntityValue, uid);
}
