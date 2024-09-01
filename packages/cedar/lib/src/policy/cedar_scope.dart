import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:collection/collection.dart';

sealed class CedarPolicyScope {
  factory CedarPolicyScope.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'principal': final Map<String, Object?> principal} =>
        CedarPrincipalScope.fromJson(principal),
      {'action': final Map<String, Object?> action} =>
        CedarActionScope.fromJson(action),
      {'resource': final Map<String, Object?> resource} =>
        CedarResourceScope.fromJson(resource),
      _ => throw ArgumentError.value(
          json,
          'json',
          'Invalid Cedar policy scope. Expected principal, action, or resource.',
        ),
    };
  }

  CedarExpr toExpr();
  CedarExpr toVariableExpr(CedarVariable variable);

  Map<String, Object?> toJson();
}

sealed class CedarPrincipalScope implements CedarPolicyScope {
  const CedarPrincipalScope();

  factory CedarPrincipalScope.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'op': 'All'} => const CedarPrincipalAll(),
      {'op': '==', 'slot': final String slotId} =>
        CedarPrincipalEquals(CedarSlotId.fromJson(slotId)),
      {'op': '==', 'entity': final Map<String, Object?> entityJson} =>
        CedarPrincipalEquals(CedarEntityId.fromJson(entityJson)),
      {'op': 'in', 'slot': final String slotId} =>
        CedarPrincipalIn(CedarSlotId.fromJson(slotId)),
      {'op': 'in', 'entity': final Map<String, Object?> entityJson} =>
        CedarPrincipalIn(CedarEntityId.fromJson(entityJson)),
      {
        'op': 'is',
        'entity_type': final String entityType,
        'in': {'slot': final String slotId}
      } =>
        CedarPrincipalIsIn(entityType, CedarSlotId.fromJson(slotId)),
      {
        'op': 'is',
        'entity_type': final String entityType,
        'in': {'entity': final Map<String, Object?> entityJson}
      } =>
        CedarPrincipalIsIn(entityType, CedarEntityId.fromJson(entityJson)),
      {'op': 'is', 'entity_type': final String entityType} =>
        CedarPrincipalIs(entityType),
      _ => throw ArgumentError.value(
          json,
          'json',
          'Invalid Cedar principal scope. Expected op in [All, ==, in, is].',
        ),
    };
  }

  @override
  CedarExpr toExpr() => toVariableExpr(CedarVariable.principal);
}

sealed class CedarActionScope implements CedarPolicyScope {
  const CedarActionScope();

  factory CedarActionScope.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'op': 'All'} => const CedarActionAll(),
      {'op': '==', 'entity': final Map<String, Object?> entityJson} =>
        CedarActionEquals(CedarEntityId.fromJson(entityJson)),
      {'op': 'in', 'entity': final Map<String, Object?> entityJson} =>
        CedarActionIn(CedarEntityId.fromJson(entityJson)),
      {'op': 'in', 'entities': final List<Object?> entities} =>
        CedarActionInSet(
          entities
              .map((o) => CedarEntityId.fromJson(o as Map<String, Object?>))
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
  CedarExpr toExpr() => toVariableExpr(CedarVariable.action);
}

sealed class CedarResourceScope implements CedarPolicyScope {
  const CedarResourceScope();

  factory CedarResourceScope.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'op': 'All'} => const CedarResourceAll(),
      {'op': '==', 'slot': final String slotId} =>
        CedarResourceEquals(CedarSlotId.fromJson(slotId)),
      {'op': '==', 'entity': final Map<String, Object?> entityJson} =>
        CedarResourceEquals(CedarEntityId.fromJson(entityJson)),
      {'op': 'in', 'slot': final String slotId} =>
        CedarResourceIn(CedarSlotId.fromJson(slotId)),
      {'op': 'in', 'entity': final Map<String, Object?> entityJson} =>
        CedarResourceIn(CedarEntityId.fromJson(entityJson)),
      {
        'op': 'is',
        'entity_type': final String entityType,
        'in': {'slot': final String slotId}
      } =>
        CedarResourceIsIn(entityType, CedarSlotId.fromJson(slotId)),
      {
        'op': 'is',
        'entity_type': final String entityType,
        'in': {'entity': final Map<String, Object?> entityJson}
      } =>
        CedarResourceIsIn(entityType, CedarEntityId.fromJson(entityJson)),
      {'op': 'is', 'entity_type': final String entityType} =>
        CedarResourceIs(entityType),
      _ => throw ArgumentError.value(
          json,
          'json',
          'Invalid Cedar resource scope. Expected op in [All, ==, in, is].',
        ),
    };
  }

  @override
  CedarExpr toExpr() => toVariableExpr(CedarVariable.resource);
}

abstract mixin class CedarScopeAll implements CedarPolicyScope {
  const CedarScopeAll();

  @override
  CedarExpr toVariableExpr(CedarVariable variable) => true_();

  @override
  Map<String, Object?> toJson() => {
        'op': 'All',
      };

  @override
  bool operator ==(Object other) {
    return other is CedarScopeAll;
  }

  @override
  int get hashCode => (CedarScopeAll).hashCode;
}

abstract mixin class CedarScopeEquals implements CedarPolicyScope {
  const CedarScopeEquals();

  CedarComponent get entity;

  @override
  CedarExpr toVariableExpr(CedarVariable variable) =>
      CedarExprVariable(variable).equals(entity.toExpr());

  @override
  Map<String, Object?> toJson() => switch (entity) {
        final CedarSlotId slotId => {'op': '==', 'slot': slotId.toJson()},
        final CedarEntityId entityId => {
            'op': '==',
            'entity': entityId.toJson()
          },
      };

  @override
  bool operator ==(Object other) {
    return other is CedarScopeEquals && entity == other.entity;
  }

  @override
  int get hashCode => Object.hash(CedarScopeEquals, entity);
}

abstract mixin class CedarScopeIn implements CedarPolicyScope {
  const CedarScopeIn();

  CedarComponent get entity;

  @override
  CedarExpr toVariableExpr(CedarVariable variable) =>
      CedarExprVariable(variable).in_(entity.toExpr());

  @override
  Map<String, Object?> toJson() => switch (entity) {
        final CedarSlotId slotId => {'op': 'in', 'slot': slotId.toJson()},
        final CedarEntityId entityId => {
            'op': 'in',
            'entity': entityId.toJson()
          },
      };

  @override
  bool operator ==(Object other) {
    return other is CedarScopeIn && entity == other.entity;
  }

  @override
  int get hashCode => Object.hash(CedarScopeIn, entity);
}

abstract mixin class CedarScopeIs implements CedarPolicyScope {
  const CedarScopeIs();

  String get entityType;

  @override
  CedarExpr toVariableExpr(CedarVariable variable) =>
      CedarExprVariable(variable).is_(entityType);

  @override
  Map<String, Object?> toJson() => {
        'op': 'is',
        'entity_type': entityType,
      };

  @override
  bool operator ==(Object other) {
    return other is CedarScopeIs && entityType == other.entityType;
  }

  @override
  int get hashCode => Object.hash(CedarScopeIs, entityType);
}

abstract mixin class CedarScopeIsIn implements CedarPolicyScope {
  const CedarScopeIsIn();

  String get entityType;
  CedarComponent get entity;

  @override
  CedarExpr toVariableExpr(CedarVariable variable) =>
      CedarExprVariable(variable).isIn(entityType, entity.toExpr());

  @override
  Map<String, Object?> toJson() => {
        'op': 'is',
        'entity_type': entityType,
        'in': switch (entity) {
          final CedarSlotId slotId => {'slot': slotId.toJson()},
          final CedarEntityId entityId => {'entity': entityId.toJson()},
        }
      };

  @override
  bool operator ==(Object other) {
    return other is CedarScopeIsIn &&
        entityType == other.entityType &&
        entity == other.entity;
  }

  @override
  int get hashCode => Object.hash(CedarScopeIsIn, entityType, entity);
}

abstract mixin class CedarScopeInSet implements CedarPolicyScope {
  const CedarScopeInSet();

  List<CedarEntityId> get entities;

  @override
  CedarExpr toVariableExpr(CedarVariable variable) =>
      CedarExprVariable(variable)
          .in_(set(entities.map((e) => e.toExpr()).toList()));

  @override
  Map<String, Object?> toJson() => {
        'op': 'in',
        'entities': entities.map((e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) {
    return other is CedarScopeInSet &&
        const ListEquality<CedarEntityId>().equals(entities, other.entities);
  }

  @override
  int get hashCode => Object.hashAll([CedarScopeInSet, ...entities]);
}

final class CedarPrincipalAll extends CedarPrincipalScope with CedarScopeAll {
  const CedarPrincipalAll();
}

final class CedarPrincipalEquals extends CedarPrincipalScope
    with CedarScopeEquals {
  const CedarPrincipalEquals(this.entity);

  @override
  final CedarComponent entity;
}

final class CedarPrincipalIn extends CedarPrincipalScope with CedarScopeIn {
  const CedarPrincipalIn(this.entity);

  @override
  final CedarComponent entity;
}

final class CedarPrincipalIs extends CedarPrincipalScope with CedarScopeIs {
  const CedarPrincipalIs(this.entityType);

  @override
  final String entityType;
}

final class CedarPrincipalIsIn extends CedarPrincipalScope with CedarScopeIsIn {
  const CedarPrincipalIsIn(this.entityType, this.entity);

  @override
  final String entityType;

  @override
  final CedarComponent entity;
}

final class CedarActionAll extends CedarActionScope with CedarScopeAll {
  const CedarActionAll();
}

final class CedarActionEquals extends CedarActionScope with CedarScopeEquals {
  const CedarActionEquals(this.entity);

  @override
  final CedarEntityId entity;
}

final class CedarActionIn extends CedarActionScope with CedarScopeIn {
  const CedarActionIn(this.entity);

  @override
  final CedarEntityId entity;
}

final class CedarActionInSet extends CedarActionScope with CedarScopeInSet {
  const CedarActionInSet(this.entities);

  @override
  final List<CedarEntityId> entities;
}

final class CedarResourceAll extends CedarResourceScope with CedarScopeAll {
  const CedarResourceAll();
}

final class CedarResourceEquals extends CedarResourceScope
    with CedarScopeEquals {
  const CedarResourceEquals(this.entity);

  @override
  final CedarComponent entity;
}

final class CedarResourceIn extends CedarResourceScope with CedarScopeIn {
  const CedarResourceIn(this.entity);

  @override
  final CedarComponent entity;
}

final class CedarResourceIs extends CedarResourceScope with CedarScopeIs {
  const CedarResourceIs(this.entityType);

  @override
  final String entityType;
}

final class CedarResourceIsIn extends CedarResourceScope with CedarScopeIsIn {
  const CedarResourceIsIn(this.entityType, this.entity);

  @override
  final String entityType;

  @override
  final CedarComponent entity;
}

extension CedarPolicyScopeBuilder on CedarPolicy {
  CedarPolicy principalEquals(CedarEntityId entity) {
    return rebuild((policy) => policy.principal = CedarPrincipalEquals(entity));
  }

  CedarPolicy principalIn(CedarEntityId entity) {
    return rebuild((policy) => policy.principal = CedarPrincipalIn(entity));
  }

  CedarPolicy principalIs(String entityType) {
    return rebuild((policy) => policy.principal = CedarPrincipalIs(entityType));
  }

  CedarPolicy principalIsIn(String entityType, CedarEntityId entity) {
    return rebuild(
        (policy) => policy.principal = CedarPrincipalIsIn(entityType, entity));
  }

  CedarPolicy actionEquals(CedarEntityId entity) {
    return rebuild((policy) => policy.action = CedarActionEquals(entity));
  }

  CedarPolicy actionIn(CedarEntityId entity) {
    return rebuild((policy) => policy.action = CedarActionIn(entity));
  }

  CedarPolicy actionInSet(Iterable<CedarEntityId> entities) {
    return rebuild(
        (policy) => policy.action = CedarActionInSet(entities.toList()));
  }

  CedarPolicy resourceEquals(CedarEntityId entity) {
    return rebuild((policy) => policy.resource = CedarResourceEquals(entity));
  }

  CedarPolicy resourceIn(CedarEntityId entity) {
    return rebuild((policy) => policy.resource = CedarResourceIn(entity));
  }

  CedarPolicy resourceIs(String entityType) {
    return rebuild((policy) => policy.resource = CedarResourceIs(entityType));
  }

  CedarPolicy resourceIsIn(String entityType, CedarEntityId entity) {
    return rebuild(
        (policy) => policy.resource = CedarResourceIsIn(entityType, entity));
  }
}
