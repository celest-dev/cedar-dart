part of 'cedar_value.dart';

@Deprecated('Use CedarString instead')
typedef CedarValueString = CedarString;

final class CedarString extends CedarValue {
  const CedarString(this.value);

  factory CedarString.fromJson(String json) {
    return CedarString(json);
  }

  final String value;

  @override
  String toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CedarString && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
