part of '../value.dart';

final class EntityValue extends Value implements Component {
  const EntityValue({required this.uid});

  factory EntityValue.fromJson(Map<String, Object?> json) {
    switch (json) {
      case {'__entity': {'type': final String type, 'id': final String id}} ||
            {'type': final String type, 'id': final String id}:
        return EntityValue(uid: EntityUid.of(type, id));
      default:
        throw FormatException('Invalid entity value JSON: $json');
    }
  }

  factory EntityValue.fromProto(pb.EntityValue entityValue) {
    return EntityValue(uid: EntityUid.fromProto(entityValue.uid));
  }

  final EntityUid uid;

  @override
  Expr toExpr() => Expr.value(this);

  @override
  Map<String, Object?> toJson() => {
        '__entity': uid.toJson(),
      };

  @override
  pb.Value toProto() => pb.Value(entity: pb.EntityValue(uid: uid.toProto()));

  @override
  String toString() => uid.toString();

  @override
  operator ==(Object other) =>
      identical(this, other) || other is EntityValue && uid == other.uid;

  @override
  int get hashCode => Object.hash(EntityValue, uid);
}
