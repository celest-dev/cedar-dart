import 'package:cedar/cedar.dart';

abstract interface class EvaluationException implements Exception {}

final class EntityNotFoundException implements EvaluationException {
  const EntityNotFoundException(this.entityId);

  final CedarEntityId entityId;

  @override
  String toString() => 'Entity `$entityId` not found';
}

final class UnspecifiedEntityException implements EvaluationException {
  const UnspecifiedEntityException();

  @override
  String toString() => 'Entity is unspecified';
}

final class TypeException implements EvaluationException {
  const TypeException(this.message);

  final String message;

  @override
  String toString() => 'Type error: $message';
}

final class AttributeAccessException implements EvaluationException {
  const AttributeAccessException(this.type, this.attribute);

  final String type;
  final String attribute;

  @override
  String toString() => '$type does not have the attribute `$attribute`';
}

final class OverflowException implements EvaluationException {
  const OverflowException(this.message);

  final String message;

  @override
  String toString() => 'Overflow error: $message';
}

final class ArityException implements EvaluationException {
  const ArityException(this.name, this.expected, this.actual);

  final String name;
  final int expected;
  final int actual;

  @override
  String toString() =>
      'Incorrect number of arguments to `$name`. Expected $expected, got $actual';
}

final class UnknownExtensionException implements EvaluationException {
  const UnknownExtensionException(this.name);

  final String name;

  @override
  String toString() => 'Unknown extension function `$name`';
}
