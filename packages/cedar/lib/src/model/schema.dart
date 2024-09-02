import 'package:cedar/cedar.dart';
import 'package:cedar/src/util/let.dart';

/// Dart representation of a Cedar [schema](https://docs.cedarpolicy.com/schema/schema.html).
final class CedarSchema {
  CedarSchema({
    Map<String, CedarNamespace>? namespaces,
  }) : _namespaces = namespaces ?? {};

  final Map<String, CedarNamespace> _namespaces;

  factory CedarSchema.fromJson(Map<String, Object?> json) {
    return CedarSchema(
      namespaces: json.map(
        (name, json) => MapEntry(
          name,
          CedarNamespace.fromJson(json as Map<String, Object?>),
        ),
      ),
    );
  }

  CedarNamespace? getNamespace(String name) {
    return _namespaces[name];
  }

  void updateNamespace(
      String name, CedarNamespace Function(CedarNamespace) updates) {
    _namespaces.update(
      name,
      (value) => updates(value),
      ifAbsent: () => updates(CedarNamespace()),
    );
  }

  Map<String, Object?> toJson() => _namespaces.map(
        (name, namespace) => MapEntry(name, namespace.toJson()),
      );
}

final class CedarNamespace {
  CedarNamespace({
    Map<String, CedarEntitySchema>? entityTypes,
    Map<String, CedarActionSchema>? actionTypes,
    Map<String, CedarType>? commonTypes,
  })  : _entityTypes = entityTypes,
        _actionTypes = actionTypes,
        _commonTypes = commonTypes;

  factory CedarNamespace.fromJson(Map<String, Object?> json) {
    return CedarNamespace(
      entityTypes: (json['entityTypes'] as Map<Object?, Object?>?)
          ?.cast<String, Object?>()
          .map(
            (name, json) => MapEntry(
              name,
              CedarEntitySchema.fromJson(
                  (json as Map<Object?, Object?>).cast()),
            ),
          ),
      actionTypes: (json['actions'] as Map<Object?, Object?>?)
          ?.cast<String, Object?>()
          .map(
            (name, json) => MapEntry(
              name,
              CedarActionSchema.fromJson(
                  (json as Map<Object?, Object?>).cast()),
            ),
          ),
      commonTypes: (json['commonTypes'] as Map<Object?, Object?>?)
          ?.cast<String, Object?>()
          .map(
            (name, json) => MapEntry(
              name,
              CedarType.fromJson((json as Map<Object?, Object?>).cast()),
            ),
          ),
    );
  }

  Map<String, CedarEntitySchema>? _entityTypes;
  Map<String, CedarActionSchema>? _actionTypes;
  Map<String, CedarType>? _commonTypes;

  void addEntitySchema(String name, CedarEntitySchema entityType) {
    (_entityTypes ??= {}).update(
      name,
      (value) => throw StateError('Entity type "$name" already exists'),
      ifAbsent: () => entityType,
    );
  }

  void addActionSchema(String name, CedarActionSchema actionType) {
    (_actionTypes ??= {}).update(
      name,
      (value) => throw StateError('Action type "$name" already exists'),
      ifAbsent: () => actionType,
    );
  }

  void addCommonType(String name, CedarTypeDefinition type) {
    (_commonTypes ??= {}).update(
      name,
      (value) => throw StateError('Common type "$name" already exists'),
      ifAbsent: () => type,
    );
  }

  Map<String, Object?> toJson() => {
        if (_entityTypes != null)
          'entityTypes': _entityTypes!.map(
            (name, entityType) => MapEntry(name, entityType.toJson()),
          ),
        if (_actionTypes != null)
          'actions': _actionTypes!.map(
            (name, actionType) => MapEntry(name, actionType.toJson()),
          ),
        if (_commonTypes != null)
          'commonTypes': _commonTypes!.map(
            (name, type) => MapEntry(name, type.toJson()),
          ),
      };
}

final class CedarEntitySchema {
  const CedarEntitySchema({
    this.memberOfTypes,
    this.shape,
  });

  factory CedarEntitySchema.fromJson(Map<String, Object?> json) {
    return CedarEntitySchema(
      memberOfTypes:
          (json['memberOfTypes'] as List<Object?>?)?.cast<String>().toList(),
      shape: (json['shape'] as Map<String, Object?>?)?.let(CedarType.fromJson),
    );
  }

  final List<String>? memberOfTypes;
  final CedarType? shape;

  Map<String, Object?> toJson() => {
        if (memberOfTypes != null) 'memberOfTypes': memberOfTypes,
        if (shape != null) 'shape': shape!.toJson(),
      };
}

final class CedarActionSchema {
  const CedarActionSchema({
    this.memberOf,
    required this.appliesTo,
  });

  factory CedarActionSchema.fromJson(Map<String, Object?> json) {
    return CedarActionSchema(
      memberOf: (json['memberOf'] as List<Object?>?)
          ?.map((json) => EntityUid.fromJson(json as Map<String, Object?>))
          .toList(),
      appliesTo: switch (json['appliesTo']) {
        null => null,
        final Map<Object?, Object?> json => CedarActionAppliesTo.fromJson(
            json.cast(),
          ),
        _ => throw ArgumentError.value(
            json,
            'json',
            'Invalid Cedar action schema',
          ),
      },
    );
  }

  final List<EntityUid>? memberOf;
  final CedarActionAppliesTo? appliesTo;

  Map<String, Object?> toJson() => {
        'memberOf': memberOf?.map((e) => e.toJson()).toList(),
        'appliesTo': appliesTo?.toJson(),
      };
}

final class CedarActionAppliesTo {
  const CedarActionAppliesTo({
    this.principalTypes,
    this.resourceTypes,
    this.contextType,
  });

  factory CedarActionAppliesTo.fromJson(Map<String, Object?> json) {
    return CedarActionAppliesTo(
      principalTypes: (json['principalTypes'] as List<Object?>?)?.cast(),
      resourceTypes: (json['resourceTypes'] as List<Object?>?)?.cast(),
      contextType: json['context'] == null
          ? null
          : CedarType.fromJson(
              (json['context'] as Map<Object?, Object?>).cast(),
            ),
    );
  }

  final List<String>? principalTypes;
  final List<String>? resourceTypes;

  /// Must be a [CedarRecordType] or a [CedarTypeReference] to a
  /// [CedarRecordType].
  final CedarType? contextType;

  Map<String, Object?> toJson() => {
        'principalTypes': principalTypes,
        'resourceTypes': resourceTypes,
        if (contextType != null) 'context': contextType!.toJson(),
      };
}
