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
  @override
  Expr toExpr() => Expr.slot(this);

  String toJson() => switch (this) {
        principal => '?principal',
        resource => '?resource',
      };
}
