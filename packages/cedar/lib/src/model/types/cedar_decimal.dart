part of 'cedar_value.dart';

final class CedarDecimal extends CedarValue {
  CedarDecimal(this.value);

  final Decimal value;

  @override
  String toString() {
    return value.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CedarDecimal && value == other.value;

  @override
  int get hashCode => Object.hash(CedarDecimal, value);

  @override
  Object? toJson() => value.toString();
}
