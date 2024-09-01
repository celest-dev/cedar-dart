part of 'cedar_value.dart';

@Deprecated('Use CedarBool instead')
typedef CedarValueBool = CedarBool;

final class CedarBool extends CedarValue {
  const CedarBool(this.value);

  factory CedarBool.fromJson(bool json) {
    return CedarBool(json);
  }

  final bool value;

  operator ~() => CedarBool(!value);
  operator &(CedarBool other) => CedarBool(value && other.value);
  operator |(CedarBool other) => CedarBool(value || other.value);
  operator ^(CedarBool other) => CedarBool(value ^ other.value);

  @override
  bool toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CedarBool && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
