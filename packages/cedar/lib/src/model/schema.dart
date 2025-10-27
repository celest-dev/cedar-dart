import 'package:cedar/cedar.dart';
import 'package:cedar/src/parser/schema_parser.dart';
import 'package:cedar/src/util/let.dart';
import 'package:logging/logging.dart';

final Logger _schemaLog = Logger('cedar.CedarSchema');

/// Dart representation of a Cedar [schema](https://docs.cedarpolicy.com/schema/schema.html).
final class CedarSchema {
  CedarSchema({Map<String, CedarNamespace>? namespaces})
    : _namespaces = namespaces ?? {};

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

  factory CedarSchema.parse(String source, {Uri? sourceUrl}) {
    if (_schemaLog.isLoggable(Level.FINE)) {
      _schemaLog.fine(
        'Parsing Cedar schema from source (length: ${source.length})',
      );
    }
    final json = SchemaParser(source, sourceUrl: sourceUrl).parse();
    if (_schemaLog.isLoggable(Level.FINER)) {
      _schemaLog.finer('Parsed namespaces: ${json.keys.toList()}');
    }
    return CedarSchema.fromJson(json);
  }

  CedarNamespace? getNamespace(String name) {
    return _namespaces[name];
  }

  void updateNamespace(
    String name,
    CedarNamespace Function(CedarNamespace) updates,
  ) {
    _namespaces.update(
      name,
      (value) => updates(value),
      ifAbsent: () => updates(CedarNamespace()),
    );
  }

  Map<String, Object?> toJson({bool normalizedUids = false}) => _namespaces.map(
    (name, namespace) =>
        MapEntry(name, namespace.toJson(normalizedUids: normalizedUids)),
  );

  /// Validates that the schema contains only well-formed references.
  ///
  /// Throws a [SchemaValidationException] if the schema is invalid.
  void validate() {
    if (_schemaLog.isLoggable(Level.FINE)) {
      _schemaLog.fine(
        'Validating schema with ${_namespaces.length} namespaces',
      );
    }
    final errors = <String>[];
    final entityIndex = <String, CedarEntitySchema>{};
    final commonTypeIndex = <String, _CommonTypeIndexEntry>{};

    _namespaces.forEach((namespaceName, namespace) {
      if (_schemaLog.isLoggable(Level.FINER)) {
        _schemaLog.finer('Indexing namespace "$namespaceName"');
      }
      namespace._entityTypes?.forEach((name, schema) {
        final qualified = _qualifiedName(namespaceName, name);
        entityIndex[qualified] = schema;
      });
      namespace._commonTypes?.forEach((name, type) {
        final qualified = _qualifiedName(namespaceName, name);
        commonTypeIndex[qualified] = _CommonTypeIndexEntry(
          namespace: namespaceName,
          name: qualified,
          type: type,
        );
      });
    });

    _namespaces.forEach((namespaceName, namespace) {
      if (_schemaLog.isLoggable(Level.FINER)) {
        _schemaLog.finer('Validating namespace "$namespaceName"');
      }
      namespace._entityTypes?.forEach((name, schema) {
        final qualified = _qualifiedName(namespaceName, name);
        if (_schemaLog.isLoggable(Level.FINER)) {
          _schemaLog.finer('Validating entity "$qualified"');
        }
        for (final member in schema.memberOfTypes ?? const <String>[]) {
          if (!entityIndex.containsKey(member)) {
            errors.add(
              'Unknown entity type "$member" in memberOf for entity $qualified',
            );
          }
        }
        if (schema.shape case final shape?) {
          _resolveAndValidateType(
            shape,
            namespaceName,
            entityIndex,
            commonTypeIndex,
            errors,
            'entity $qualified shape',
          );
        }
        if (schema.tags case final tags?) {
          _resolveAndValidateType(
            tags,
            namespaceName,
            entityIndex,
            commonTypeIndex,
            errors,
            'tags of entity $qualified',
          );
        }
      });

      namespace._actionTypes?.forEach((name, action) {
        final qualified = _qualifiedName(namespaceName, name);
        if (_schemaLog.isLoggable(Level.FINER)) {
          _schemaLog.finer('Validating action "$qualified"');
        }
        for (final member in action.memberOf ?? const <EntityUid>[]) {
          if (!entityIndex.containsKey(member.type)) {
            errors.add(
              'Unknown entity type "${member.type}" in memberOf for action $qualified',
            );
          }
        }

        final appliesTo = action.appliesTo;
        if (appliesTo != null) {
          for (final principal
              in appliesTo.principalTypes ?? const <String>[]) {
            if (!entityIndex.containsKey(principal)) {
              errors.add(
                'Unknown principal entity type "$principal" for action $qualified',
              );
            }
          }
          for (final resource in appliesTo.resourceTypes ?? const <String>[]) {
            if (!entityIndex.containsKey(resource)) {
              errors.add(
                'Unknown resource entity type "$resource" for action $qualified',
              );
            }
          }
          if (appliesTo.contextType != null) {
            final resolved = _resolveAndValidateType(
              appliesTo.contextType!,
              namespaceName,
              entityIndex,
              commonTypeIndex,
              errors,
              'context of action $qualified',
            );
            if (resolved != null && resolved is! CedarRecordType) {
              errors.add('Context for action $qualified must be a record type');
            }
          }
        }
      });

      namespace._commonTypes?.forEach((name, type) {
        final qualified = _qualifiedName(namespaceName, name);
        if (_schemaLog.isLoggable(Level.FINER)) {
          _schemaLog.finer('Validating common type "$qualified"');
        }
        _resolveAndValidateType(
          type,
          namespaceName,
          entityIndex,
          commonTypeIndex,
          errors,
          'type $qualified',
          initialAlias: qualified,
        );
      });
    });

    if (errors.isNotEmpty) {
      if (_schemaLog.isLoggable(Level.WARNING)) {
        for (final error in errors) {
          _schemaLog.warning('Schema validation error: $error');
        }
      }
      throw SchemaValidationException(errors.join('\n'));
    }
    if (_schemaLog.isLoggable(Level.FINE)) {
      _schemaLog.fine('Schema validation completed successfully');
    }
  }
}

final class CedarNamespace {
  CedarNamespace({
    Map<String, CedarEntitySchema>? entityTypes,
    Map<String, CedarActionSchema>? actionTypes,
    Map<String, CedarType>? commonTypes,
  }) : _entityTypes = entityTypes,
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
                (json as Map<Object?, Object?>).cast(),
              ),
            ),
          ),
      actionTypes: (json['actions'] as Map<Object?, Object?>?)
          ?.cast<String, Object?>()
          .map(
            (name, json) => MapEntry(
              name,
              CedarActionSchema.fromJson(
                (json as Map<Object?, Object?>).cast(),
              ),
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

  Map<String, Object?> toJson({bool normalizedUids = false}) => {
    if (_entityTypes != null)
      'entityTypes': _entityTypes!.map(
        (name, entityType) => MapEntry(name, entityType.toJson()),
      ),
    if (_actionTypes != null)
      'actions': Map.fromEntries(
        _actionTypes!.entries.map(
          (entry) => MapEntry(
            normalizedUids
                ? EntityUid(
                    const EntityTypeName('Action'),
                    EntityId(entry.key),
                  ).normalized.id
                : entry.key,
            entry.value.toJson(normalizedUids: normalizedUids),
          ),
        ),
      ),
    if (_commonTypes != null)
      'commonTypes': _commonTypes!.map(
        (name, type) => MapEntry(name, type.toJson()),
      ),
  };
}

final class CedarEntitySchema {
  const CedarEntitySchema({this.memberOfTypes, this.shape, this.tags});

  factory CedarEntitySchema.fromJson(Map<String, Object?> json) {
    return CedarEntitySchema(
      memberOfTypes: (json['memberOfTypes'] as List<Object?>?)
          ?.cast<String>()
          .toList(),
      shape: (json['shape'] as Map<String, Object?>?)?.let(CedarType.fromJson),
      tags: (json['tags'] as Map<String, Object?>?)?.let(CedarType.fromJson),
    );
  }

  final List<String>? memberOfTypes;
  final CedarType? shape;
  final CedarType? tags;

  Map<String, Object?> toJson() => {
    if (memberOfTypes != null) 'memberOfTypes': memberOfTypes,
    if (shape != null) 'shape': shape!.toJson(),
    if (tags != null) 'tags': tags!.toJson(),
  };
}

final class CedarActionSchema {
  const CedarActionSchema({this.memberOf, required this.appliesTo});

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

  Map<String, Object?> toJson({bool normalizedUids = false}) => {
    'memberOf': memberOf
        ?.map((e) => (normalizedUids ? e.normalized : e).toJson())
        .toList(),
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

CedarType? _resolveAndValidateType(
  CedarType type,
  String namespace,
  Map<String, CedarEntitySchema> entityIndex,
  Map<String, _CommonTypeIndexEntry> commonTypeIndex,
  List<String> errors,
  String context, {
  Set<String>? stack,
  String? initialAlias,
}) {
  if (_schemaLog.isLoggable(Level.FINER)) {
    _schemaLog.finer(
      'Resolving type ${type.runtimeType} for $context (namespace: "$namespace")',
    );
  }
  final effectiveStack = stack ?? <String>{};
  if (initialAlias != null) {
    effectiveStack.add(initialAlias);
    if (_schemaLog.isLoggable(Level.FINEST)) {
      _schemaLog.finest(
        'Initial alias "$initialAlias" added to resolution stack',
      );
    }
  }

  CedarType? resolve(CedarType current, String currentNamespace) {
    if (_schemaLog.isLoggable(Level.FINEST)) {
      _schemaLog.finest(
        'Visiting ${current.runtimeType} while resolving $context (namespace: "$currentNamespace")',
      );
    }
    switch (current) {
      case CedarBooleanType():
      case CedarStringType():
      case CedarLongType():
      case CedarIpAddressType():
      case CedarDecimalType():
      case CedarDatetimeType():
      case CedarDurationType():
        return current;
      case CedarSetType(elementType: final elementType):
        resolve(elementType, currentNamespace);
        return current;
      case CedarRecordType(attributes: final attributes):
        for (final entry in attributes.entries) {
          if (_schemaLog.isLoggable(Level.FINEST)) {
            _schemaLog.finest(
              'Resolving record attribute "${entry.key}" (${entry.value.runtimeType}) in $context',
            );
          }
          resolve(entry.value, currentNamespace);
        }
        return current;
      case CedarEntityType(entityName: final entityName):
        if (!entityIndex.containsKey(entityName)) {
          errors.add('Unknown entity type "$entityName" in $context');
        }
        return current;
      case CedarTypeReference(type: final reference):
        if (_schemaLog.isLoggable(Level.FINER)) {
          _schemaLog.finer(
            'Resolving type reference "$reference" for $context (namespace: "$currentNamespace")',
          );
        }
        final resolved = _resolveCommonType(
          reference,
          currentNamespace,
          commonTypeIndex,
        );
        if (resolved == null) {
          if (_schemaLog.isLoggable(Level.FINE)) {
            _schemaLog.fine(
              'Failed to resolve type reference "$reference" for $context (namespace: "$currentNamespace")',
            );
          }
          errors.add('Unknown type "$reference" in $context');
          return null;
        }
        final added = effectiveStack.add(resolved.name);
        if (_schemaLog.isLoggable(Level.FINEST)) {
          _schemaLog.finest(
            'Resolved "$reference" to common type "${resolved.name}" (stack size: ${effectiveStack.length})',
          );
        }
        if (!added) {
          if (_schemaLog.isLoggable(Level.WARNING)) {
            _schemaLog.warning(
              'Recursive type reference detected while resolving ${resolved.name} in $context',
            );
          }
          errors.add(
            'Recursive type reference detected for ${resolved.name} in $context',
          );
          return null;
        }
        try {
          return resolve(resolved.type, resolved.namespace);
        } finally {
          effectiveStack.remove(resolved.name);
          if (_schemaLog.isLoggable(Level.FINEST)) {
            _schemaLog.finest(
              'Removed "${resolved.name}" from resolution stack',
            );
          }
        }
    }
  }

  final result = resolve(type, namespace);
  if (initialAlias != null) {
    effectiveStack.remove(initialAlias);
    if (_schemaLog.isLoggable(Level.FINEST)) {
      _schemaLog.finest(
        'Initial alias "$initialAlias" removed from resolution stack',
      );
    }
  }
  if (_schemaLog.isLoggable(Level.FINER)) {
    _schemaLog.finer('Finished resolving $context; success: ${result != null}');
  }
  return result;
}

_CommonTypeIndexEntry? _resolveCommonType(
  String reference,
  String namespace,
  Map<String, _CommonTypeIndexEntry> index,
) {
  if (_schemaLog.isLoggable(Level.FINER)) {
    _schemaLog.finer(
      'Resolving common type reference "$reference" starting from namespace "$namespace"',
    );
  }
  final candidates = _candidateNames(namespace, reference);
  for (final candidate in candidates) {
    if (_schemaLog.isLoggable(Level.FINEST)) {
      _schemaLog.finest(
        'Trying candidate "$candidate" for reference "$reference"',
      );
    }
    final entry = index[candidate];
    if (entry != null) {
      if (_schemaLog.isLoggable(Level.FINER)) {
        _schemaLog.finer(
          'Resolved common type reference "$reference" to "${entry.name}"',
        );
      }
      return entry;
    }
  }
  if (_schemaLog.isLoggable(Level.FINER)) {
    _schemaLog.finer(
      'Unable to resolve common type reference "$reference" from namespace "$namespace"',
    );
  }
  return null;
}

Iterable<String> _candidateNames(String namespace, String reference) sync* {
  if (reference.contains('::')) {
    yield reference;
  } else {
    if (namespace.isNotEmpty) {
      yield '$namespace::$reference';
    }
    yield reference;
  }
}

String _qualifiedName(String namespace, String name) {
  if (namespace.isEmpty) {
    return name;
  }
  return '$namespace::$name';
}

final class _CommonTypeIndexEntry {
  const _CommonTypeIndexEntry({
    required this.namespace,
    required this.name,
    required this.type,
  });

  final String namespace;
  final String name;
  final CedarType type;
}
