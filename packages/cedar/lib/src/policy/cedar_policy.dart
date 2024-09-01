/// Provides builders and serializers for Cedar policies which conform to the
/// official JSON format.
///
/// See:
/// - https://docs.cedarpolicy.com/auth/authorization.html
/// - https://docs.cedarpolicy.com/policies/json-format.html
library;

import 'package:cedar/ast.dart';
import 'package:cedar/src/parser/parser.dart';
import 'package:cedar/src/parser/tokenizer.dart';

enum CedarEffect {
  permit,
  forbid;

  factory CedarEffect.fromJson(String json) {
    return CedarEffect.values.byName(json);
  }

  String toJson() => name;
}

enum CedarConditionKind {
  when,
  unless;

  factory CedarConditionKind.fromJson(String json) {
    return CedarConditionKind.values.byName(json);
  }

  String toJson() => name;
}

final class CedarPolicy {
  const CedarPolicy({
    required this.effect,
    this.principal = const CedarPrincipalAll(),
    this.action = const CedarActionAll(),
    this.resource = const CedarResourceAll(),
    this.conditions = const [],
    this.annotations,
    this.position,
  });

  factory CedarPolicy.fromJson(Map<String, dynamic> json) {
    return CedarPolicy(
      effect: CedarEffect.fromJson(json['effect'] as String),
      principal: CedarPrincipalScope.fromJson(
        json['principal'] as Map<String, Object?>,
      ),
      action: CedarActionScope.fromJson(
        json['action'] as Map<String, Object?>,
      ),
      resource: CedarResourceScope.fromJson(
        json['resource'] as Map<String, Object?>,
      ),
      conditions: (json['conditions'] as List<Object?>)
          .map((c) => CedarCondition.fromJson(c as Map<String, Object?>))
          .toList(),
      annotations: json['annotations'] == null
          ? null
          : Annotations.fromJson(json['annotations'] as Map<String, Object?>),
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, Object?>),
    );
  }

  factory CedarPolicy.parse(String cedar) {
    final tokens = Tokenizer(cedar).tokenize();
    final parser = Parser(tokens);
    final policy = parser.readPolicy();
    parser.expectEof();
    return policy;
  }

  const CedarPolicy.permit() : this(effect: CedarEffect.permit);
  const CedarPolicy.forbid() : this(effect: CedarEffect.forbid);

  final CedarEffect effect;
  final CedarPrincipalScope principal;
  final CedarActionScope action;
  final CedarResourceScope resource;
  final List<CedarCondition> conditions;
  final Annotations? annotations;
  final Position? position;

  bool get isTemplate {
    final visitor = _IsTemplateVisitor();
    principal.toExpr().accept(visitor);
    if (visitor.isTemplate) return true;
    resource.toExpr().accept(visitor);
    if (visitor.isTemplate) return true;
    return false;
  }

  CedarPolicy rebuild(void Function(CedarPolicyBuilder policy) builder) {
    final policy = toBuilder();
    builder(policy);
    return policy.build();
  }

  CedarPolicyBuilder toBuilder() {
    return CedarPolicyBuilder()
      ..effect = effect
      ..principal = principal
      ..action = action
      ..resource = resource
      ..conditions = List.of(conditions)
      ..annotations =
          annotations == null ? null : Annotations(annotations!.annotations)
      ..position = position;
  }

  CedarPolicy when(CedarExpr expr) {
    return rebuild((policy) => policy.when(expr));
  }

  CedarPolicy unless(CedarExpr expr) {
    return rebuild((policy) => policy.unless(expr));
  }

  CedarPolicy annotate(String key, String value) {
    return rebuild(
        (policy) => (policy.annotations ??= Annotations({}))[key] = value);
  }

  CedarExpr toExpr() {
    final exprs = <CedarExpr>[
      principal.toExpr(),
      action.toExpr(),
      resource.toExpr(),
    ];
    for (final condition in conditions) {
      switch (condition.kind) {
        case CedarConditionKind.when:
          exprs.add(condition.body);
        case CedarConditionKind.unless:
          exprs.add(not(condition.body));
      }
    }
    var res = exprs.last;
    for (var i = exprs.length - 2; i >= 0; i--) {
      res = exprs[i].and(res);
    }
    return res;
  }

  Map<String, Object?> toJson() => {
        'effect': effect.toJson(),
        'principal': principal.toJson(),
        'action': action.toJson(),
        'resource': resource.toJson(),
        'conditions': conditions.map((c) => c.toJson()).toList(),
        if (annotations case final annotations?)
          'annotations': annotations.toJson(),
        if (position case final position?) 'position': position.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarPolicy &&
          effect == other.effect &&
          principal == other.principal &&
          action == other.action &&
          resource == other.resource &&
          conditions == other.conditions &&
          annotations == other.annotations &&
          position == other.position;

  @override
  int get hashCode => Object.hash(
        effect,
        principal,
        action,
        resource,
        conditions,
        annotations,
        position,
      );
}

final class CedarPolicyBuilder {
  CedarPolicyBuilder();

  CedarEffect? effect;
  CedarPrincipalScope? principal;
  CedarActionScope? action;
  CedarResourceScope? resource;
  List<CedarCondition>? conditions;
  Annotations? annotations;
  Position? position;

  CedarPolicyBuilder when(CedarExpr expr) {
    conditions ??= [];
    conditions!.add(CedarCondition(
      kind: CedarConditionKind.when,
      body: expr,
    ));
    return this;
  }

  CedarPolicyBuilder unless(CedarExpr expr) {
    conditions ??= [];
    conditions!.add(CedarCondition(
      kind: CedarConditionKind.unless,
      body: expr,
    ));
    return this;
  }

  CedarPolicyBuilder annotate(String key, String value) {
    annotations ??= Annotations({});
    annotations![key] = value;
    return this;
  }

  CedarPolicy build() {
    return CedarPolicy(
      effect: effect ?? CedarEffect.permit,
      principal: principal ?? const CedarPrincipalAll(),
      action: action ?? const CedarActionAll(),
      resource: resource ?? const CedarResourceAll(),
      conditions: conditions ?? const [],
      annotations: annotations,
      position: position,
    );
  }
}

final class CedarCondition {
  const CedarCondition({
    required this.kind,
    required this.body,
  });

  final CedarConditionKind kind;
  final CedarExpr body;

  Map<String, Object?> toJson() => {
        'kind': kind.toJson(),
        'body': body.toJson(),
      };

  factory CedarCondition.fromJson(Map<String, Object?> json) => CedarCondition(
        kind: CedarConditionKind.fromJson(json['kind'] as String),
        body: CedarExpr.fromJson(json['body'] as Map<String, Object?>),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarCondition && kind == other.kind && body == other.body;

  @override
  int get hashCode => Object.hash(kind, body);
}

final class _IsTemplateVisitor extends DefaultExprVisitor<void> {
  var isTemplate = false;

  @override
  void visitEquals(CedarExprEquals equals) {
    if (equals.right case CedarExprSlot()) {
      isTemplate = true;
    }
  }

  @override
  void visitIn(CedarExprIn in_) {
    if (in_.right case CedarExprSlot()) {
      isTemplate = true;
    }
  }

  @override
  void visitIs(CedarExprIs is_) {
    if (is_.inExpr case CedarExprSlot()) {
      isTemplate = true;
    }
  }
}
