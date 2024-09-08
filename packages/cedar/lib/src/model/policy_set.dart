import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:cedar/src/parser/parser.dart';
import 'package:cedar/src/parser/tokenizer.dart';
import 'package:cedar/src/util/pretty_json.dart';
import 'package:collection/collection.dart';

part 'policy_set.g.dart';

/// A collection of Cedar policies.
abstract class PolicySet
    implements CedarAuthorizer, Built<PolicySet, PolicySetBuilder> {
  factory PolicySet({
    Map<String, Policy> policies = const {},
    Map<String, Policy> templates = const {},
    List<TemplateLink> templateLinks = const [],
  }) {
    return _$PolicySet._(
      policies: policies.build(),
      templates: templates.build(),
      templateLinks: templateLinks.build(),
    );
  }

  const PolicySet._();

  factory PolicySet.build([void Function(PolicySetBuilder) updates]) =
      _$PolicySet;

  factory PolicySet.fromJson(Map<String, Object?> json) {
    return PolicySet(
      policies:
          (json['staticPolicies'] as Map<String, Object?>? ?? const {}).map(
        (k, v) => MapEntry(
          k,
          Policy.fromJson(v as Map<String, Object?>),
        ),
      ),
      templates: (json['templates'] as Map<String, Object?>? ?? const {}).map(
        (k, v) => MapEntry(
          k,
          Policy.fromJson(v as Map<String, Object?>),
        ),
      ),
      templateLinks: (json['templateLinks'] as List<Object?>? ?? const [])
          .map((l) => TemplateLink.fromJson(l as Map<String, Object?>))
          .toList(),
    );
  }

  factory PolicySet.parse(String cedar) {
    final tokens = Tokenizer(cedar).tokenize();
    final parser = Parser(tokens);
    final policies = <String, Policy>{};
    final templates = <String, Policy>{};
    var polIndex = 0, tmplIndex = 0;
    while (!parser.isDone) {
      final policyOrTemplate = parser.readPolicy();
      var id = policyOrTemplate.annotations?['id'];
      if (policyOrTemplate.isTemplate) {
        templates[id ?? 'template${tmplIndex++}'] = policyOrTemplate;
      } else {
        policies[id ?? 'policy${polIndex++}'] = policyOrTemplate;
      }
    }
    return PolicySet(policies: policies, templates: templates);
  }

  BuiltMap<String, Policy> get policies;
  BuiltMap<String, Policy> get templates;
  BuiltList<TemplateLink> get templateLinks;

  Map<String, Object?> toJson() => {
        'staticPolicies':
            policies.map((key, value) => MapEntry(key, value.toJson())).toMap(),
        'templates': templates
            .map((key, value) => MapEntry(key, value.toJson()))
            .toMap(),
        'templateLinks': templateLinks.map((link) => link.toJson()).toList(),
      };

  @override
  AuthorizationResponse isAuthorized(AuthorizationRequest request) {
    final context = EvaluationContext(
      entities: request.entities,
      principal: request.principal ?? EntityUid.unknown(),
      action: request.action ?? EntityUid.unknown(),
      resource: request.resource ?? EntityUid.unknown(),
      context: RecordValue(request.context ?? const {}),
    );
    final evaluator = Evalutator(context);

    final diagnostics = <AuthorizationException>[];
    final permitReasons = <String>[];
    final forbidReasons = <String>[];
    var forbidden = false;
    var permitted = false;

    // Don't try to short circuit this.
    // - Even though single forbid means forbid
    // - All policy should be run to collect errors
    // - For permit, all permits must be run to collect annotations
    // - For forbid, forbids must be run to collect annotations
    for (final MapEntry(key: id, value: policy) in policies.entries) {
      try {
        final result = policy.toExpr().accept(evaluator).expectBool();
        if (!result.value) {
          continue;
        }
        if (policy.effect == Effect.forbid) {
          forbidden = true;
          forbidReasons.add(id);
        } else {
          permitted = true;
          permitReasons.add(id);
        }
      } on EvaluationException catch (e) {
        diagnostics.add(AuthorizationException(
          policyId: id,
          message: e.toString(),
        ));
      }
    }

    final reasons = permitted ? permitReasons : forbidReasons;
    return AuthorizationResponse(
      decision: permitted && !forbidden ? Decision.allow : Decision.deny,
      reasons: reasons.isEmpty ? null : reasons,
      errors: diagnostics.isEmpty ? null : AuthorizationErrors(diagnostics),
    );
  }

  static Serializer<PolicySet> get serializer => _$policySetSerializer;
}

final class TemplateLink {
  const TemplateLink({
    required this.templateId,
    required this.newId,
    required this.values,
  });

  final String templateId;
  final String newId;
  final Map<SlotId, EntityUid> values;

  Map<String, Object?> toJson() => {
        'templateId': templateId,
        'newId': newId,
        'values': values.map((k, v) => MapEntry(k.toJson(), v.toString())),
      };

  factory TemplateLink.fromJson(Map<String, Object?> json) {
    return TemplateLink(
      templateId: json['templateId'] as String,
      newId: json['newId'] as String,
      values: (json['values'] as Map<String, Object?>).map(
        (k, v) => MapEntry(
          SlotId.fromJson(k),
          EntityUid.fromJson(v as Map<String, Object?>),
        ),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TemplateLink &&
      templateId == other.templateId &&
      newId == other.newId &&
      const MapEquality().equals(values, other.values);

  @override
  int get hashCode => Object.hashAll([templateId, newId, ...values.entries]);

  @override
  String toString() => prettyJson(toJson());
}
