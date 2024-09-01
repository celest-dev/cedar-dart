part of 'cedar_value.dart';

enum CedarSlotId implements CedarComponent {
  principal,
  resource;

  factory CedarSlotId.fromJson(String json) {
    return CedarSlotId.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () =>
          throw ArgumentError.value(json, 'json', 'Invalid Cedar slot ID'),
    );
  }
  @override
  CedarExpr toExpr() => CedarExpr.slot(this);

  String toJson() => switch (this) {
        principal => '?principal',
        resource => '?resource',
      };
}
