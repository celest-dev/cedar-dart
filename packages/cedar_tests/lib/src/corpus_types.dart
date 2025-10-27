import 'package:cedar/cedar.dart';

typedef CedarTestLoader = CedarTest Function();

final class CedarTest {
  const CedarTest({
    required this.name,
    required this.schemaJson,
    required this.policiesCedar,
    required this.shouldValidate,
    required this.entitiesJson,
    required this.queries,
  });

  factory CedarTest.fromJson(Map<String, Object?> json) {
    final schema = json['schema_json'];
    final entities = json['entities_json'];
    final queriesJson = json['queries'];
    if (schema is! Map) {
      throw const FormatException('Missing schema_json map in CedarTest');
    }
    if (entities is! List) {
      throw const FormatException('Missing entities_json list in CedarTest');
    }
    if (queriesJson is! List) {
      throw const FormatException('Missing queries list in CedarTest');
    }
    return CedarTest(
      name: json['name'] as String,
      schemaJson: Map<String, Object?>.from(schema),
      policiesCedar: json['policies_cedar'] as String,
      shouldValidate: (json['should_validate'] as bool?) ?? true,
      entitiesJson: List<Object?>.from(entities),
      queries: queriesJson
          .map(
            (query) =>
                CedarQuery.fromJson(Map<String, Object?>.from(query as Map)),
          )
          .toList(growable: false),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'schema_json': Map<String, Object?>.from(schemaJson),
    'policies_cedar': policiesCedar,
    'should_validate': shouldValidate,
    'entities_json': List<Object?>.from(entitiesJson),
    'queries': queries.map((query) => query.toJson()).toList(growable: false),
  };

  final String name;
  final Map<String, Object?> schemaJson;
  final String policiesCedar;
  final bool shouldValidate;
  final List<Object?> entitiesJson;
  final List<CedarQuery> queries;
}

final class CedarQuery {
  const CedarQuery({
    required this.description,
    required this.principal,
    required this.resource,
    required this.action,
    required this.context,
    required this.decision,
    required this.reasons,
    required this.errors,
  });

  factory CedarQuery.fromJson(Map<String, Object?> json) {
    final contextJson = json['context'];
    if (contextJson is! Map) {
      throw FormatException('Invalid context for query: $json');
    }
    final reasonsJson = json['reasons'];
    final errorsJson = json['errors'];
    if (reasonsJson is! List) {
      throw FormatException('Invalid reasons list for query: $json');
    }
    if (errorsJson is! List) {
      throw FormatException('Invalid errors list for query: $json');
    }
    return CedarQuery(
      description: json['desc'] as String,
      principal: _entityUidFromJson(json['principal']),
      resource: _entityUidFromJson(json['resource']),
      action: _entityUidFromJson(json['action'])!,
      context: contextJson as Map<String, Object?>,
      decision: _decisionFromJson(json['decision']),
      reasons: reasonsJson
          .map((entry) => entry.toString())
          .toList(growable: false),
      errors: errorsJson
          .map((entry) => entry.toString())
          .toList(growable: false),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'desc': description,
    'principal': principal?.toJson(),
    'resource': resource?.toJson(),
    'action': action.toJson(),
    'context': Map<String, Object?>.from(context),
    'decision': _decisionToJson(decision),
    'reasons': List<String>.from(reasons),
    'errors': List<String>.from(errors),
  };

  final String description;
  final EntityUid? principal;
  final EntityUid? resource;
  final EntityUid action;
  final Map<String, Object?> context;
  final Decision decision;
  final List<String> reasons;
  final List<String> errors;
}

EntityUid? _entityUidFromJson(Object? value) {
  if (value is Map<String, Object?>) {
    return EntityUid.fromJson(value);
  }
  if (value is Map) {
    return EntityUid.fromJson(Map<String, Object?>.from(value));
  }
  if (value == null) {
    return null;
  }
  throw FormatException('Invalid EntityUid JSON: $value');
}

Decision _decisionFromJson(Object? value) {
  return switch (value) {
    'Allow' => Decision.allow,
    'Deny' => Decision.deny,
    final String other => throw FormatException(
      'Unknown decision value: $other',
    ),
    _ => throw FormatException('Invalid decision value: $value'),
  };
}

String _decisionToJson(Decision decision) => switch (decision) {
  Decision.allow => 'Allow',
  Decision.deny => 'Deny',
};
