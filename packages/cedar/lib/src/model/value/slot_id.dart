part of '../value.dart';

enum SlotId implements Component {
  principal,
  resource;

  factory SlotId.fromJson(String json) {
    return SlotId.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () =>
          throw ArgumentError.value(json, 'json', 'Invalid Cedar slot ID'),
    );
  }

  factory SlotId.fromProto(pb.SlotId slotId) {
    return switch (slotId) {
      pb.SlotId.SLOT_ID_PRINCIPAL => SlotId.principal,
      pb.SlotId.SLOT_ID_RESOURCE => SlotId.resource,
      _ => throw FormatException('Invalid Cedar slot ID: ${slotId.name}'),
    };
  }

  @override
  Expr toExpr() => Expr.slot(this);

  String toJson() => switch (this) {
        principal => '?principal',
        resource => '?resource',
      };

  pb.SlotId toProto() => switch (this) {
        principal => pb.SlotId.SLOT_ID_PRINCIPAL,
        resource => pb.SlotId.SLOT_ID_RESOURCE,
      };
}
