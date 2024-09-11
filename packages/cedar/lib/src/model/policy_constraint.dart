import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/proto/cedar/v3/policy.pb.dart' as pb;
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

  factory PrincipalConstraint.fromProto(pb.PrincipalConstraint proto) {
    return switch (proto.whichConstraint()) {
      pb.PrincipalConstraint_Constraint.all => const PrincipalAll(),
      pb.PrincipalConstraint_Constraint.equals =>
        PrincipalEquals.fromProto(proto.equals),
      pb.PrincipalConstraint_Constraint.in_ => PrincipalIn.fromProto(proto.in_),
      pb.PrincipalConstraint_Constraint.is_5 =>
        PrincipalIs.fromProto(proto.is_5),
      pb.PrincipalConstraint_Constraint.isIn =>
        PrincipalIsIn.fromProto(proto.isIn),
      final unknown => throw ArgumentError.value(
          unknown,
          'constraint',
          'Unknown Cedar principal constraint.',
        ),
    };
  }

  @override
  Expr toExpr() => toVariableExpr(CedarVariable.principal);

  pb.PrincipalConstraint toProto();
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

  factory ActionConstraint.fromProto(pb.ActionConstraint proto) {
    return switch (proto.whichConstraint()) {
      pb.ActionConstraint_Constraint.all => const ActionAll(),
      pb.ActionConstraint_Constraint.equals =>
        ActionEquals.fromProto(proto.equals),
      pb.ActionConstraint_Constraint.in_ => ActionIn.fromProto(proto.in_),
      pb.ActionConstraint_Constraint.inSet =>
        ActionInSet(proto.inSet.entities.map(EntityUid.fromProto).toList()),
      final unknown => throw ArgumentError.value(
          unknown,
          'constraint',
          'Unknown Cedar action constraint.',
        ),
    };
  }

  @override
  Expr toExpr() => toVariableExpr(CedarVariable.action);

  pb.ActionConstraint toProto();
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

  factory ResourceConstraint.fromProto(pb.ResourceConstraint proto) {
    return switch (proto.whichConstraint()) {
      pb.ResourceConstraint_Constraint.all => const ResourceAll(),
      pb.ResourceConstraint_Constraint.equals =>
        ResourceEquals.fromProto(proto.equals),
      pb.ResourceConstraint_Constraint.in_ => ResourceIn.fromProto(proto.in_),
      pb.ResourceConstraint_Constraint.is_5 => ResourceIs.fromProto(proto.is_5),
      pb.ResourceConstraint_Constraint.isIn =>
        ResourceIsIn.fromProto(proto.isIn),
      final unknown => throw ArgumentError.value(
          unknown,
          'constraint',
          'Unknown Cedar resource constraint.',
        ),
    };
  }

  @override
  Expr toExpr() => toVariableExpr(CedarVariable.resource);

  pb.ResourceConstraint toProto();
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

  @override
  pb.PrincipalConstraint toProto() => pb.PrincipalConstraint(
        all: pb.PrincipalAll(),
      );
}

final class PrincipalEquals extends PrincipalConstraint
    with PolicyConstraintEquals {
  const PrincipalEquals(this.entity);

  factory PrincipalEquals.fromProto(pb.PrincipalEquals proto) {
    return PrincipalEquals(
      switch (proto.whichComponent()) {
        pb.PrincipalEquals_Component.slot => SlotId.fromProto(proto.slot),
        pb.PrincipalEquals_Component.entity =>
          EntityUid.fromProto(proto.entity),
        final unknown => throw ArgumentError.value(
            unknown,
            'entity',
            'Unknown Cedar principal equals entity.',
          ),
      },
    );
  }

  @override
  final Component entity;

  @override
  pb.PrincipalConstraint toProto() => pb.PrincipalConstraint(
        equals: switch (entity) {
          final SlotId slot => pb.PrincipalEquals(slot: slot.toProto()),
          final EntityUid uid ||
          EntityValue(:final uid) =>
            pb.PrincipalEquals(entity: uid.toProto()),
        },
      );
}

final class PrincipalIn extends PrincipalConstraint with PolicyConstraintIn {
  const PrincipalIn(this.entity);

  factory PrincipalIn.fromProto(pb.PrincipalIn proto) {
    return PrincipalIn(
      switch (proto.whichComponent()) {
        pb.PrincipalIn_Component.slot => SlotId.fromProto(proto.slot),
        pb.PrincipalIn_Component.entity => EntityUid.fromProto(proto.entity),
        final unknown => throw ArgumentError.value(
            unknown,
            'entity',
            'Unknown Cedar principal in entity.',
          ),
      },
    );
  }

  @override
  final Component entity;

  @override
  pb.PrincipalConstraint toProto() => pb.PrincipalConstraint(
        in_: switch (entity) {
          final SlotId slot => pb.PrincipalIn(slot: slot.toProto()),
          final EntityUid uid ||
          EntityValue(:final uid) =>
            pb.PrincipalIn(entity: uid.toProto()),
        },
      );
}

final class PrincipalIs extends PrincipalConstraint with PolicyConstraintIs {
  const PrincipalIs(this.entityType);

  factory PrincipalIs.fromProto(pb.PrincipalIs proto) {
    return PrincipalIs(proto.entityType);
  }

  @override
  final String entityType;

  @override
  pb.PrincipalConstraint toProto() => pb.PrincipalConstraint(
        is_5: pb.PrincipalIs(entityType: entityType),
      );
}

final class PrincipalIsIn extends PrincipalConstraint
    with PolicyConstraintIsIn {
  const PrincipalIsIn(this.entityType, this.entity);

  factory PrincipalIsIn.fromProto(pb.PrincipalIsIn proto) {
    return PrincipalIsIn(
      proto.entityType,
      switch (proto.whichIn()) {
        pb.PrincipalIsIn_In.slot => SlotId.fromProto(proto.slot),
        pb.PrincipalIsIn_In.entity => EntityUid.fromProto(proto.entity),
        final unknown => throw ArgumentError.value(
            unknown,
            'entity',
            'Unknown Cedar principal is in entity.',
          ),
      },
    );
  }

  @override
  final String entityType;

  @override
  final Component entity;

  @override
  pb.PrincipalConstraint toProto() => pb.PrincipalConstraint(
        isIn: switch (entity) {
          final SlotId slot => pb.PrincipalIsIn(
              entityType: entityType,
              slot: slot.toProto(),
            ),
          final EntityUid uid || EntityValue(:final uid) => pb.PrincipalIsIn(
              entityType: entityType,
              entity: uid.toProto(),
            ),
        },
      );
}

final class ActionAll extends ActionConstraint with PolicyConstraintAll {
  const ActionAll();

  @override
  pb.ActionConstraint toProto() => pb.ActionConstraint(
        all: pb.ActionAll(),
      );
}

final class ActionEquals extends ActionConstraint with PolicyConstraintEquals {
  const ActionEquals(this.entity);

  factory ActionEquals.fromProto(pb.ActionEquals proto) {
    return ActionEquals(EntityUid.fromProto(proto.entity));
  }

  @override
  final EntityUid entity;

  @override
  pb.ActionConstraint toProto() => pb.ActionConstraint(
        equals: pb.ActionEquals(entity: entity.toProto()),
      );
}

final class ActionIn extends ActionConstraint with PolicyConstraintIn {
  const ActionIn(this.entity);

  factory ActionIn.fromProto(pb.ActionIn proto) {
    return ActionIn(EntityUid.fromProto(proto.entity));
  }

  @override
  final EntityUid entity;

  @override
  pb.ActionConstraint toProto() => pb.ActionConstraint(
        in_: pb.ActionIn(entity: entity.toProto()),
      );
}

final class ActionInSet extends ActionConstraint with PolicyConstraintInSet {
  const ActionInSet(this.entities);

  factory ActionInSet.fromProto(pb.ActionInSet proto) {
    return ActionInSet(proto.entities.map(EntityUid.fromProto).toList());
  }

  @override
  final List<EntityUid> entities;

  @override
  pb.ActionConstraint toProto() => pb.ActionConstraint(
        inSet: pb.ActionInSet(
          entities: entities.map((e) => e.toProto()).toList(),
        ),
      );
}

final class ResourceAll extends ResourceConstraint with PolicyConstraintAll {
  const ResourceAll();

  @override
  pb.ResourceConstraint toProto() => pb.ResourceConstraint(
        all: pb.ResourceAll(),
      );
}

final class ResourceEquals extends ResourceConstraint
    with PolicyConstraintEquals {
  const ResourceEquals(this.entity);

  factory ResourceEquals.fromProto(pb.ResourceEquals proto) {
    return ResourceEquals(
      switch (proto.whichComponent()) {
        pb.ResourceEquals_Component.slot => SlotId.fromProto(proto.slot),
        pb.ResourceEquals_Component.entity => EntityUid.fromProto(proto.entity),
        final unknown => throw ArgumentError.value(
            unknown,
            'entity',
            'Unknown Cedar resource equals entity.',
          ),
      },
    );
  }

  @override
  final Component entity;

  @override
  pb.ResourceConstraint toProto() => pb.ResourceConstraint(
        equals: switch (entity) {
          final SlotId slot => pb.ResourceEquals(slot: slot.toProto()),
          final EntityUid uid ||
          EntityValue(:final uid) =>
            pb.ResourceEquals(entity: uid.toProto()),
        },
      );
}

final class ResourceIn extends ResourceConstraint with PolicyConstraintIn {
  const ResourceIn(this.entity);

  factory ResourceIn.fromProto(pb.ResourceIn proto) {
    return ResourceIn(
      switch (proto.whichComponent()) {
        pb.ResourceIn_Component.slot => SlotId.fromProto(proto.slot),
        pb.ResourceIn_Component.entity => EntityUid.fromProto(proto.entity),
        final unknown => throw ArgumentError.value(
            unknown,
            'entity',
            'Unknown Cedar resource in entity.',
          ),
      },
    );
  }

  @override
  final Component entity;

  @override
  pb.ResourceConstraint toProto() => pb.ResourceConstraint(
        in_: switch (entity) {
          final SlotId slot => pb.ResourceIn(slot: slot.toProto()),
          final EntityUid uid ||
          EntityValue(:final uid) =>
            pb.ResourceIn(entity: uid.toProto()),
        },
      );
}

final class ResourceIs extends ResourceConstraint with PolicyConstraintIs {
  const ResourceIs(this.entityType);

  factory ResourceIs.fromProto(pb.ResourceIs proto) {
    return ResourceIs(proto.entityType);
  }

  @override
  final String entityType;

  @override
  pb.ResourceConstraint toProto() => pb.ResourceConstraint(
        is_5: pb.ResourceIs(entityType: entityType),
      );
}

final class ResourceIsIn extends ResourceConstraint with PolicyConstraintIsIn {
  const ResourceIsIn(this.entityType, this.entity);

  factory ResourceIsIn.fromProto(pb.ResourceIsIn proto) {
    return ResourceIsIn(
      proto.entityType,
      switch (proto.whichIn()) {
        pb.ResourceIsIn_In.slot => SlotId.fromProto(proto.slot),
        pb.ResourceIsIn_In.entity => EntityUid.fromProto(proto.entity),
        final unknown => throw ArgumentError.value(
            unknown,
            'entity',
            'Unknown Cedar resource is in entity.',
          ),
      },
    );
  }

  @override
  final String entityType;

  @override
  final Component entity;

  @override
  pb.ResourceConstraint toProto() => pb.ResourceConstraint(
        isIn: switch (entity) {
          final SlotId slot => pb.ResourceIsIn(
              entityType: entityType,
              slot: slot.toProto(),
            ),
          final EntityUid uid || EntityValue(:final uid) => pb.ResourceIsIn(
              entityType: entityType,
              entity: uid.toProto(),
            ),
        },
      );
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
