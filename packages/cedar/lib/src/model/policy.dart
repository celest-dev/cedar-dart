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

enum Effect {
  permit,
  forbid;

  factory Effect.fromJson(String json) {
    return Effect.values.byName(json);
  }

  String toJson() => name;
}

enum ConditionKind {
  when,
  unless;

  factory ConditionKind.fromJson(String json) {
    return ConditionKind.values.byName(json);
  }

  String toJson() => name;
}

final class Policy {
  const Policy({
    required this.effect,
    this.principal = const PrincipalAll(),
    this.action = const ActionAll(),
    this.resource = const ResourceAll(),
    this.conditions = const [],
    this.annotations,
    this.position,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      effect: Effect.fromJson(json['effect'] as String),
      principal: PrincipalConstraint.fromJson(
        json['principal'] as Map<String, Object?>,
      ),
      action: ActionConstraint.fromJson(
        json['action'] as Map<String, Object?>,
      ),
      resource: ResourceConstraint.fromJson(
        json['resource'] as Map<String, Object?>,
      ),
      conditions: (json['conditions'] as List<Object?>)
          .map((c) => Condition.fromJson(c as Map<String, Object?>))
          .toList(),
      annotations: json['annotations'] == null
          ? null
          : Annotations.fromJson(json['annotations'] as Map<String, Object?>),
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, Object?>),
    );
  }

  factory Policy.parse(String cedar) {
    final tokens = Tokenizer(cedar).tokenize();
    final parser = Parser(tokens);
    final policy = parser.readPolicy();
    parser.expectEof();
    return policy;
  }

  const Policy.permit() : this(effect: Effect.permit);
  const Policy.forbid() : this(effect: Effect.forbid);

  final Effect effect;
  final PrincipalConstraint principal;
  final ActionConstraint action;
  final ResourceConstraint resource;
  final List<Condition> conditions;
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

  Policy rebuild(void Function(PolicyBuilder policy) builder) {
    final policy = toBuilder();
    builder(policy);
    return policy.build();
  }

  PolicyBuilder toBuilder() {
    return PolicyBuilder()
      ..effect = effect
      ..principal = principal
      ..action = action
      ..resource = resource
      ..conditions = List.of(conditions)
      ..annotations =
          annotations == null ? null : Annotations(annotations!.annotations)
      ..position = position;
  }

  Policy when(Expr expr) {
    return rebuild((policy) => policy.when(expr));
  }

  Policy unless(Expr expr) {
    return rebuild((policy) => policy.unless(expr));
  }

  Policy annotate(String key, String value) {
    return rebuild(
        (policy) => (policy.annotations ??= Annotations({}))[key] = value);
  }

  Expr toExpr() {
    final exprs = <Expr>[
      principal.toExpr(),
      action.toExpr(),
      resource.toExpr(),
    ];
    for (final condition in conditions) {
      switch (condition.kind) {
        case ConditionKind.when:
          exprs.add(condition.body);
        case ConditionKind.unless:
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
      other is Policy &&
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

final class PolicyBuilder {
  PolicyBuilder();

  Effect? effect;
  PrincipalConstraint? principal;
  ActionConstraint? action;
  ResourceConstraint? resource;
  List<Condition>? conditions;
  Annotations? annotations;
  Position? position;

  PolicyBuilder when(Expr expr) {
    conditions ??= [];
    conditions!.add(Condition(
      kind: ConditionKind.when,
      body: expr,
    ));
    return this;
  }

  PolicyBuilder unless(Expr expr) {
    conditions ??= [];
    conditions!.add(Condition(
      kind: ConditionKind.unless,
      body: expr,
    ));
    return this;
  }

  PolicyBuilder annotate(String key, String value) {
    annotations ??= Annotations({});
    annotations![key] = value;
    return this;
  }

  Policy build() {
    return Policy(
      effect: effect ?? Effect.permit,
      principal: principal ?? const PrincipalAll(),
      action: action ?? const ActionAll(),
      resource: resource ?? const ResourceAll(),
      conditions: conditions ?? const [],
      annotations: annotations,
      position: position,
    );
  }
}

final class Condition {
  const Condition({
    required this.kind,
    required this.body,
  });

  final ConditionKind kind;
  final Expr body;

  Map<String, Object?> toJson() => {
        'kind': kind.toJson(),
        'body': body.toJson(),
      };

  factory Condition.fromJson(Map<String, Object?> json) => Condition(
        kind: ConditionKind.fromJson(json['kind'] as String),
        body: Expr.fromJson(json['body'] as Map<String, Object?>),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Condition && kind == other.kind && body == other.body;

  @override
  int get hashCode => Object.hash(kind, body);
}

final class _IsTemplateVisitor extends DefaultExprVisitor<void> {
  var isTemplate = false;

  @override
  void visitEquals(ExprEquals equals) {
    if (equals.right case ExprSlot()) {
      isTemplate = true;
    }
  }

  @override
  void visitIn(ExprIn in_) {
    if (in_.right case ExprSlot()) {
      isTemplate = true;
    }
  }

  @override
  void visitIs(ExprIs is_) {
    if (is_.inExpr case ExprSlot()) {
      isTemplate = true;
    }
  }
}
