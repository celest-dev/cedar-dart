import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:collection/collection.dart';

sealed class PolicyConstraint {
  factory PolicyConstraint.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'principal': final Map<String, Object?> principal} =>
        PrincipalConstraint.fromJson(principal),
      {'action': final Map<String, Object?> action} =>
        ActionConstraint.fromJson(action),
      {'resource': final Map<String, Object?> resource} =>
        ResourceConstraint.fromJson(resource),
      _ => throw ArgumentError.value(
          json,
          'json',
          'Invalid Cedar policy scope. Expected principal, action, or resource.',
        ),
    };
  }

  Expr toExpr();
  Expr toVariableExpr(CedarVariable variable);

  Map<String, Object?> toJson();
}

sealed class PrincipalConstraint implements PolicyConstraint {
  const PrincipalConstraint();

  factory PrincipalConstraint.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'op': 'All'} => const PrincipalAll(),
      {'op': '==', 'slot': final String slotId} =>
        PrincipalEquals(SlotId.fromJson(slotId)),
      {'op': '==', 'entity': final Map<String, Object?> entityJson} =>
        PrincipalEquals(EntityValue(
          uid: EntityUid.fromJson(entityJson),
        )),
      {'op': 'in', 'slot': final String slotId} =>
        PrincipalIn(SlotId.fromJson(slotId)),
      {'op': 'in', 'entity': final Map<String, Object?> entityJson} =>
        PrincipalIn(EntityValue(
          uid: EntityUid.fromJson(entityJson),
        )),
      {
        'op': 'is',
        'entity_type': final String entityType,
        'in': {'slot': final String slotId}
      } =>
        PrincipalIsIn(entityType, SlotId.fromJson(slotId)),
      {
        'op': 'is',
        'entity_type': final String entityType,
        'in': {'entity': final Map<String, Object?> entityJson}
      } =>
        PrincipalIsIn(
          entityType,
          EntityValue(
            uid: EntityUid.fromJson(entityJson),
          ),
        ),
      {'op': 'is', 'entity_type': final String entityType} =>
        PrincipalIs(entityType),
      _ => throw ArgumentError.value(
          json,
          'json',
          'Invalid Cedar principal scope. Expected op in [All, ==, in, is].',
        ),
    };
  }

  @override
  Expr toExpr() => toVariableExpr(CedarVariable.principal);
}

sealed class ActionConstraint implements PolicyConstraint {
  const ActionConstraint();

  factory ActionConstraint.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'op': 'All'} => const ActionAll(),
      {'op': '==', 'entity': final Map<String, Object?> entityJson} =>
        ActionEquals(EntityUid.fromJson(entityJson)),
      {'op': 'in', 'entity': final Map<String, Object?> entityJson} =>
        ActionIn(EntityUid.fromJson(entityJson)),
      {'op': 'in', 'entities': final List<Object?> entities} => ActionInSet(
          entities
              .map((o) => EntityUid.fromJson(o as Map<String, Object?>))
              .toList(),
        ),
      _ => throw ArgumentError.value(
          json,
          'json',
          'Invalid Cedar action scope. Expected op in [All, ==, in].',
        ),
    };
  }

  @override
  Expr toExpr() => toVariableExpr(CedarVariable.action);
}

sealed class ResourceConstraint implements PolicyConstraint {
  const ResourceConstraint();

  factory ResourceConstraint.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'op': 'All'} => const ResourceAll(),
      {'op': '==', 'slot': final String slotId} =>
        ResourceEquals(SlotId.fromJson(slotId)),
      {'op': '==', 'entity': final Map<String, Object?> entityJson} =>
        ResourceEquals(EntityValue(
          uid: EntityUid.fromJson(entityJson),
        )),
      {'op': 'in', 'slot': final String slotId} =>
        ResourceIn(SlotId.fromJson(slotId)),
      {'op': 'in', 'entity': final Map<String, Object?> entityJson} =>
        ResourceIn(EntityValue(
          uid: EntityUid.fromJson(entityJson),
        )),
      {
        'op': 'is',
        'entity_type': final String entityType,
        'in': {'slot': final String slotId}
      } =>
        ResourceIsIn(entityType, SlotId.fromJson(slotId)),
      {
        'op': 'is',
        'entity_type': final String entityType,
        'in': {'entity': final Map<String, Object?> entityJson}
      } =>
        ResourceIsIn(
          entityType,
          EntityValue(
            uid: EntityUid.fromJson(entityJson),
          ),
        ),
      {'op': 'is', 'entity_type': final String entityType} =>
        ResourceIs(entityType),
      _ => throw ArgumentError.value(
          json,
          'json',
          'Invalid Cedar resource scope. Expected op in [All, ==, in, is].',
        ),
    };
  }

  @override
  Expr toExpr() => toVariableExpr(CedarVariable.resource);
}

abstract mixin class PolicyConstraintAll implements PolicyConstraint {
  const PolicyConstraintAll();

  @override
  Expr toVariableExpr(CedarVariable variable) => true_();

  @override
  Map<String, Object?> toJson() => {
        'op': 'All',
      };

  @override
  bool operator ==(Object other) {
    return other is PolicyConstraintAll;
  }

  @override
  int get hashCode => (PolicyConstraintAll).hashCode;
}

abstract mixin class PolicyConstraintEquals implements PolicyConstraint {
  const PolicyConstraintEquals();

  Component get entity;

  @override
  Expr toVariableExpr(CedarVariable variable) =>
      ExprVariable(variable).equals(entity.toExpr());

  @override
  Map<String, Object?> toJson() => switch (entity) {
        final SlotId slotId => {'op': '==', 'slot': slotId.toJson()},
        final EntityUid uid || EntityValue(:final uid) => {
            'op': '==',
            'entity': uid.toJson()
          },
      };

  @override
  bool operator ==(Object other) {
    return other is PolicyConstraintEquals && entity == other.entity;
  }

  @override
  int get hashCode => Object.hash(PolicyConstraintEquals, entity);
}

abstract mixin class PolicyConstraintIn implements PolicyConstraint {
  const PolicyConstraintIn();

  Component get entity;

  @override
  Expr toVariableExpr(CedarVariable variable) =>
      ExprVariable(variable).in_(entity.toExpr());

  @override
  Map<String, Object?> toJson() => switch (entity) {
        final SlotId slotId => {'op': 'in', 'slot': slotId.toJson()},
        final EntityUid uid || EntityValue(:final uid) => {
            'op': 'in',
            'entity': uid.toJson()
          },
      };

  @override
  bool operator ==(Object other) {
    return other is PolicyConstraintIn && entity == other.entity;
  }

  @override
  int get hashCode => Object.hash(PolicyConstraintIn, entity);
}

abstract mixin class PolicyConstraintIs implements PolicyConstraint {
  const PolicyConstraintIs();

  String get entityType;

  @override
  Expr toVariableExpr(CedarVariable variable) =>
      ExprVariable(variable).is_(entityType);

  @override
  Map<String, Object?> toJson() => {
        'op': 'is',
        'entity_type': entityType,
      };

  @override
  bool operator ==(Object other) {
    return other is PolicyConstraintIs && entityType == other.entityType;
  }

  @override
  int get hashCode => Object.hash(PolicyConstraintIs, entityType);
}

abstract mixin class PolicyConstraintIsIn implements PolicyConstraint {
  const PolicyConstraintIsIn();

  String get entityType;
  Component get entity;

  @override
  Expr toVariableExpr(CedarVariable variable) =>
      ExprVariable(variable).isIn(entityType, entity.toExpr());

  @override
  Map<String, Object?> toJson() => {
        'op': 'is',
        'entity_type': entityType,
        'in': switch (entity) {
          final SlotId slotId => {'slot': slotId.toJson()},
          final EntityUid uid || EntityValue(:final uid) => {
              'entity': uid.toJson()
            },
        }
      };

  @override
  bool operator ==(Object other) {
    return other is PolicyConstraintIsIn &&
        entityType == other.entityType &&
        entity == other.entity;
  }

  @override
  int get hashCode => Object.hash(PolicyConstraintIsIn, entityType, entity);
}

abstract mixin class PolicyConstraintInSet implements PolicyConstraint {
  const PolicyConstraintInSet();

  List<EntityUid> get entities;

  @override
  Expr toVariableExpr(CedarVariable variable) =>
      ExprVariable(variable).in_(set(entities.map((e) => e.toExpr()).toList()));

  @override
  Map<String, Object?> toJson() => {
        'op': 'in',
        'entities': entities.map((e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) {
    return other is PolicyConstraintInSet &&
        const ListEquality<EntityUid>().equals(entities, other.entities);
  }

  @override
  int get hashCode => Object.hashAll([PolicyConstraintInSet, ...entities]);
}

final class PrincipalAll extends PrincipalConstraint with PolicyConstraintAll {
  const PrincipalAll();
}

final class PrincipalEquals extends PrincipalConstraint
    with PolicyConstraintEquals {
  const PrincipalEquals(this.entity);

  @override
  final Component entity;
}

final class PrincipalIn extends PrincipalConstraint with PolicyConstraintIn {
  const PrincipalIn(this.entity);

  @override
  final Component entity;
}

final class PrincipalIs extends PrincipalConstraint with PolicyConstraintIs {
  const PrincipalIs(this.entityType);

  @override
  final String entityType;
}

final class PrincipalIsIn extends PrincipalConstraint
    with PolicyConstraintIsIn {
  const PrincipalIsIn(this.entityType, this.entity);

  @override
  final String entityType;

  @override
  final Component entity;
}

final class ActionAll extends ActionConstraint with PolicyConstraintAll {
  const ActionAll();
}

final class ActionEquals extends ActionConstraint with PolicyConstraintEquals {
  const ActionEquals(this.entity);

  @override
  final EntityUid entity;
}

final class ActionIn extends ActionConstraint with PolicyConstraintIn {
  const ActionIn(this.entity);

  @override
  final EntityUid entity;
}

final class ActionInSet extends ActionConstraint with PolicyConstraintInSet {
  const ActionInSet(this.entities);

  @override
  final List<EntityUid> entities;
}

final class ResourceAll extends ResourceConstraint with PolicyConstraintAll {
  const ResourceAll();
}

final class ResourceEquals extends ResourceConstraint
    with PolicyConstraintEquals {
  const ResourceEquals(this.entity);

  @override
  final Component entity;
}

final class ResourceIn extends ResourceConstraint with PolicyConstraintIn {
  const ResourceIn(this.entity);

  @override
  final Component entity;
}

final class ResourceIs extends ResourceConstraint with PolicyConstraintIs {
  const ResourceIs(this.entityType);

  @override
  final String entityType;
}

final class ResourceIsIn extends ResourceConstraint with PolicyConstraintIsIn {
  const ResourceIsIn(this.entityType, this.entity);

  @override
  final String entityType;

  @override
  final Component entity;
}

extension PolicyConstraintBuilder on Policy {
  Policy principalEquals(EntityUid entity) {
    return rebuild(
      (policy) => policy.principal = PrincipalEquals(EntityValue(uid: entity)),
    );
  }

  Policy principalIn(EntityUid entity) {
    return rebuild(
        (policy) => policy.principal = PrincipalIn(EntityValue(uid: entity)));
  }

  Policy principalIs(String entityType) {
    return rebuild((policy) => policy.principal = PrincipalIs(entityType));
  }

  Policy principalIsIn(String entityType, EntityUid entity) {
    return rebuild((policy) =>
        policy.principal = PrincipalIsIn(entityType, EntityValue(uid: entity)));
  }

  Policy actionEquals(EntityUid entity) {
    return rebuild((policy) => policy.action = ActionEquals(entity));
  }

  Policy actionIn(EntityUid entity) {
    return rebuild((policy) => policy.action = ActionIn(entity));
  }

  Policy actionInSet(Iterable<EntityUid> entities) {
    return rebuild((policy) => policy.action = ActionInSet(entities.toList()));
  }

  Policy resourceEquals(EntityUid entity) {
    return rebuild(
        (policy) => policy.resource = ResourceEquals(EntityValue(uid: entity)));
  }

  Policy resourceIn(EntityUid entity) {
    return rebuild(
        (policy) => policy.resource = ResourceIn(EntityValue(uid: entity)));
  }

  Policy resourceIs(String entityType) {
    return rebuild((policy) => policy.resource = ResourceIs(entityType));
  }

  Policy resourceIsIn(String entityType, EntityUid entity) {
    return rebuild((policy) =>
        policy.resource = ResourceIsIn(entityType, EntityValue(uid: entity)));
  }
}
