import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:cedar/src/parser/parser.dart';
import 'package:cedar/src/parser/tokenizer.dart';
import 'package:cedar/src/util/pretty_json.dart';
import 'package:collection/collection.dart';

/// A collection of Cedar policies.
final class CedarPolicySet implements CedarAuthorizer {
  const CedarPolicySet({
    this.policies = const {},
    this.templates = const {},
    this.templateLinks = const [],
  });

  factory CedarPolicySet.fromJson(Map<String, Object?> json) {
    return CedarPolicySet(
      policies:
          (json['staticPolicies'] as Map<String, Object?>? ?? const {}).map(
        (k, v) => MapEntry(
          k,
          CedarPolicy.fromJson(v as Map<String, Object?>),
        ),
      ),
      templates: (json['templates'] as Map<String, Object?>? ?? const {}).map(
        (k, v) => MapEntry(
          k,
          CedarPolicy.fromJson(v as Map<String, Object?>),
        ),
      ),
      templateLinks: (json['templateLinks'] as List<Object?>? ?? const [])
          .map((l) => CedarTemplateLink.fromJson(l as Map<String, Object?>))
          .toList(),
    );
  }

  factory CedarPolicySet.parse(String cedar) {
    final tokens = Tokenizer(cedar).tokenize();
    final parser = Parser(tokens);
    final policies = <String, CedarPolicy>{};
    final templates = <String, CedarPolicy>{};
    var polIndex = 0, tmplIndex = 0;
    while (!parser.isDone) {
      final policyOrTemplate = parser.readPolicy();
      var id = policyOrTemplate.annotations?['id'];
      if (policyOrTemplate.isTemplate) {
        templates[id ?? 'template$tmplIndex'] = policyOrTemplate;
        tmplIndex++;
      } else {
        policies[id ?? 'policy$polIndex'] = policyOrTemplate;
        polIndex++;
      }
    }
    return CedarPolicySet(policies: policies, templates: templates);
  }

  final Map<String, CedarPolicy> policies;
  final Map<String, CedarPolicy> templates;
  final List<CedarTemplateLink> templateLinks;

  Map<String, Object?> toJson() => {
        'staticPolicies':
            policies.map((key, value) => MapEntry(key, value.toJson())),
        'templates':
            templates.map((key, value) => MapEntry(key, value.toJson())),
        'templateLinks': templateLinks.map((link) => link.toJson()).toList(),
      };

  @override
  CedarAuthorizationResponse isAuthorized(CedarAuthorizationRequest request) {
    final context = EvaluationContext(
      entities: request.entities,
      principal: request.principal ?? CedarEntityId.unknown(),
      action: request.action ?? CedarEntityId.unknown(),
      resource: request.resource ?? CedarEntityId.unknown(),
      context: CedarRecord(request.context ?? const {}),
    );
    final evaluator = Evalutator(context);

    final diagnostics = <CedarAuthorizationError>[];
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
        if (policy.effect == CedarEffect.forbid) {
          forbidden = true;
          forbidReasons.add(id);
        } else {
          permitted = true;
          permitReasons.add(id);
        }
      } on EvaluationException catch (e) {
        diagnostics.add(CedarAuthorizationError(
          policyId: id,
          message: e.toString(),
        ));
      }
    }

    final reasons = permitted ? permitReasons : forbidReasons;
    return CedarAuthorizationResponse(
      decision: permitted && !forbidden
          ? CedarAuthorizationDecision.allow
          : CedarAuthorizationDecision.deny,
      reasons: reasons.isEmpty ? null : reasons,
      errors:
          diagnostics.isEmpty ? null : CedarAuthorizationErrors(diagnostics),
    );
  }
}

final class CedarTemplateLink {
  const CedarTemplateLink({
    required this.templateId,
    required this.newId,
    required this.values,
  });

  final String templateId;
  final String newId;
  final Map<CedarSlotId, CedarEntityId> values;

  Map<String, Object?> toJson() => {
        'templateId': templateId,
        'newId': newId,
        'values': values.map((k, v) => MapEntry(k.toJson(), v.toString())),
      };

  factory CedarTemplateLink.fromJson(Map<String, Object?> json) {
    return CedarTemplateLink(
      templateId: json['templateId'] as String,
      newId: json['newId'] as String,
      values: (json['values'] as Map<String, Object?>).map(
        (k, v) => MapEntry(
          CedarSlotId.fromJson(k),
          CedarEntityId.fromJson(v as Map<String, Object?>),
        ),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CedarTemplateLink &&
      templateId == other.templateId &&
      newId == other.newId &&
      const MapEquality().equals(values, other.values);

  @override
  int get hashCode => Object.hashAll([templateId, newId, ...values.entries]);

  @override
  String toString() => prettyJson(toJson());
}
