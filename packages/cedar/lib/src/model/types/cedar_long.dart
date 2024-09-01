part of 'cedar_value.dart';

@Deprecated('Use CedarLong instead')
typedef CedarValueLong = CedarLong;

final class CedarLong extends CedarValue {
  const CedarLong(this.value);

  factory CedarLong.fromJson(int json) {
    return CedarLong(json);
  }

  final int value;

  @override
  int toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CedarLong && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
