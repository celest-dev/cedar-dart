import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:cedar/src/parser/parser.dart';
import 'package:cedar/src/parser/tokenizer.dart';
import 'package:cedar/src/proto/cedar/v4/policy.pb.dart' as pb;
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
      policies: (json['staticPolicies'] as Map<String, Object?>? ?? const {})
          .map(
            (k, v) => MapEntry(k, Policy.fromJson(v as Map<String, Object?>)),
          ),
      templates: (json['templates'] as Map<String, Object?>? ?? const {}).map(
        (k, v) => MapEntry(k, Policy.fromJson(v as Map<String, Object?>)),
      ),
      templateLinks: (json['templateLinks'] as List<Object?>? ?? const [])
          .map((l) => TemplateLink.fromJson(l as Map<String, Object?>))
          .toList(),
    );
  }

  factory PolicySet.fromProto(pb.PolicySet proto) {
    return PolicySet(
      policies: proto.policies.map(
        (id, policy) => MapEntry(id, Policy.fromProto(policy)),
      ),
      templates: proto.templates.map(
        (id, template) => MapEntry(id, Policy.fromProto(template)),
      ),
      templateLinks: proto.templateLinks
          .map((link) => TemplateLink.fromProto(link))
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

  Map<String, Object?> toJson({bool normalizedUids = false}) => {
    'templates': templates
        .map(
          (key, value) =>
              MapEntry(key, value.toJson(normalizedUids: normalizedUids)),
        )
        .toMap(),
    'staticPolicies': policies
        .map(
          (key, value) =>
              MapEntry(key, value.toJson(normalizedUids: normalizedUids)),
        )
        .toMap(),
    'templateLinks': templateLinks
        .map((link) => link.toJson(normalizedUids: normalizedUids))
        .toList(),
  };

  pb.PolicySet toProto() {
    return pb.PolicySet(
      policies: policies.entries.map(
        (entry) => MapEntry(entry.key, entry.value.toProto()),
      ),
      templates: templates.entries.map(
        (entry) => MapEntry(entry.key, entry.value.toProto()),
      ),
      templateLinks: templateLinks.map((link) => link.toProto()).toList(),
    );
  }

  PolicySet merge(PolicySet? other) {
    if (other == null) {
      return this;
    }
    return rebuild((b) {
      b.policies.addEntries(other.policies.entries);
      b.templates.addEntries(other.templates.entries);
      b.templateLinks.addAll(other.templateLinks);
    });
  }

  @override
  AuthorizationResponse isAuthorized(AuthorizationRequest request) {
    final context = EvaluationContext(
      entities: request.entities,
      principal: request.principal,
      action: request.action,
      resource: request.resource,
      context: RecordValue(request.context ?? const {}),
    );
    final evaluator = Evalutator(context);

    final diagnostics = <AuthorizationException>[];
    final permitReasons = <AuthorizationReason>[];
    final forbidReasons = <AuthorizationReason>[];
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
          forbidReasons.add(_reasonForPolicy(id: id, policy: policy));
        } else {
          permitted = true;
          permitReasons.add(_reasonForPolicy(id: id, policy: policy));
        }
      } on EvaluationException catch (e) {
        diagnostics.add(
          AuthorizationException(
            policyId: id,
            message: e.toString(),
            category: AuthorizationErrorCategory.evaluation,
            annotations: _annotationsFor(policy),
            position: policy.position,
          ),
        );
      }
    }

    for (final link in templateLinks) {
      final template = templates[link.templateId];
      if (template == null) {
        diagnostics.add(
          AuthorizationException(
            policyId: link.newId,
            message:
                'Template `${link.templateId}` not found for link `${link.newId}`',
            category: AuthorizationErrorCategory.linking,
            annotations: {'templateId': link.templateId},
          ),
        );
        continue;
      }

      final requiredSlots = template.slotIds;
      final providedSlots = link.values.keys.toSet();
      final missing = [
        for (final slot in requiredSlots)
          if (!providedSlots.contains(slot)) slot,
      ];
      final extra = [
        for (final slot in providedSlots)
          if (!requiredSlots.contains(slot)) slot,
      ];

      if (missing.isNotEmpty || extra.isNotEmpty) {
        diagnostics.add(
          AuthorizationException(
            policyId: link.newId,
            message: _linkingErrorMessage(
              templateId: link.templateId,
              missing: missing,
              extra: extra,
            ),
            category: AuthorizationErrorCategory.linking,
            annotations: _annotationsFor(
              template,
              additional: {'templateId': link.templateId},
            ),
            position: template.position,
          ),
        );
        continue;
      }

      final substituted = template.toExpr().substituteSlots(
        link.values.map((slot, uid) => MapEntry(slot, Value.entity(uid: uid))),
      );

      try {
        final result = substituted.accept(evaluator).expectBool();
        if (!result.value) {
          continue;
        }
        if (template.effect == Effect.forbid) {
          forbidden = true;
          forbidReasons.add(
            _reasonForPolicy(
              id: link.newId,
              policy: template,
              templateId: link.templateId,
              additionalAnnotations: {'templateId': link.templateId},
            ),
          );
        } else {
          permitted = true;
          permitReasons.add(
            _reasonForPolicy(
              id: link.newId,
              policy: template,
              templateId: link.templateId,
              additionalAnnotations: {'templateId': link.templateId},
            ),
          );
        }
      } on EvaluationException catch (e) {
        diagnostics.add(
          AuthorizationException(
            policyId: link.newId,
            message: e.toString(),
            category: AuthorizationErrorCategory.evaluation,
            annotations: _annotationsFor(
              template,
              additional: {'templateId': link.templateId},
            ),
            position: template.position,
          ),
        );
      } on StateError catch (e) {
        diagnostics.add(
          AuthorizationException(
            policyId: link.newId,
            message: e.toString(),
            category: AuthorizationErrorCategory.internal,
            annotations: _annotationsFor(
              template,
              additional: {'templateId': link.templateId},
            ),
            position: template.position,
          ),
        );
      }
    }

    final decision = permitted && !forbidden ? Decision.allow : Decision.deny;
    final reasons = switch (decision) {
      Decision.allow => permitReasons,
      Decision.deny => forbidReasons,
    };
    return AuthorizationResponse(
      decision: decision,
      diagnostics: AuthorizationDiagnostics(
        reasons: reasons,
        errors: diagnostics,
      ),
    );
  }

  static Serializer<PolicySet> get serializer => _$policySetSerializer;

  static String _linkingErrorMessage({
    required String templateId,
    required List<SlotId> missing,
    required List<SlotId> extra,
  }) {
    final parts = <String>[];
    if (missing.isNotEmpty) {
      final slots = missing.map((slot) => slot.toJson()).join(', ');
      parts.add('missing values for $slots');
    }
    if (extra.isNotEmpty) {
      final slots = extra.map((slot) => slot.toJson()).join(', ');
      parts.add('unexpected bindings for $slots');
    }
    final detail = parts.join('; ');
    return 'Invalid template link for template `$templateId`: $detail';
  }
}

AuthorizationReason _reasonForPolicy({
  required String id,
  required Policy policy,
  String? templateId,
  Map<String, String>? additionalAnnotations,
}) {
  return AuthorizationReason(
    policyId: id,
    effect: policy.effect,
    position: policy.position,
    templateId: templateId,
    annotations: _annotationsFor(policy, additional: additionalAnnotations),
  );
}

Map<String, String>? _annotationsFor(
  Policy policy, {
  Map<String, String>? additional,
}) {
  final hasBase = policy.annotations?.annotations.isNotEmpty ?? false;
  final hasAdditional = additional?.isNotEmpty ?? false;
  if (!hasBase && !hasAdditional) {
    return null;
  }
  final map = <String, String>{
    if (hasBase) ...policy.annotations!.annotations,
    if (hasAdditional) ...additional!,
  };
  return Map.unmodifiable(map);
}

final class TemplateLink {
  const TemplateLink({
    required this.templateId,
    required this.newId,
    required this.values,
  });

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

  factory TemplateLink.fromProto(pb.TemplateLink proto) {
    return TemplateLink(
      templateId: proto.templateId,
      newId: proto.newId,
      values: proto.values.map(
        (k, v) => MapEntry(SlotId.fromJson(k), EntityUid.fromProto(v)),
      ),
    );
  }

  final String templateId;
  final String newId;
  final Map<SlotId, EntityUid> values;

  Map<String, Object?> toJson({bool normalizedUids = false}) => {
    'templateId': templateId,
    'newId': newId,
    'values': values.map(
      (k, v) =>
          MapEntry(k.toJson(), (normalizedUids ? v.normalized : v).toJson()),
    ),
  };

  pb.TemplateLink toProto() {
    return pb.TemplateLink(
      templateId: templateId,
      newId: newId,
      values: values.entries.map(
        (entry) => MapEntry(entry.key.toJson(), entry.value.toProto()),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TemplateLink &&
      templateId == other.templateId &&
      newId == other.newId &&
      const MapEquality<SlotId, EntityUid>().equals(values, other.values);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash([templateId, newId, values]);

  @override
  String toString() => prettyJson(toJson());
}
