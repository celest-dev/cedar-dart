part of 'cedar_value.dart';

@Deprecated('Use CedarSet instead')
typedef CedarValueSet = CedarSet;

final class CedarSet extends CedarValue {
  const CedarSet(this.elements);

  factory CedarSet.fromJson(List<Object?> json) {
    return CedarSet([
      for (final element in json) CedarValue.fromJson(element),
    ]);
  }

  final List<CedarValue> elements;

  @override
  List<Object?> toJson() => [
        for (final element in elements) element.toJson(),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarSet &&
          const UnorderedIterableEquality().equals(elements, other.elements);

  @override
  int get hashCode => Object.hashAllUnordered(elements);
}
