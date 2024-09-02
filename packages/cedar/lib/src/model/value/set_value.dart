part of '../value.dart';

final class SetValue extends Value {
  const SetValue(this.elements);

  factory SetValue.fromJson(List<Object?> json) {
    return SetValue([
      for (final element in json) Value.fromJson(element),
    ]);
  }

  final List<Value> elements;

  @override
  List<Object?> toJson() => [
        for (final element in elements) element.toJson(),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetValue &&
          const UnorderedIterableEquality().equals(elements, other.elements);

  @override
  int get hashCode => Object.hashAllUnordered(elements);
}
