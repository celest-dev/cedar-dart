import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:test/test.dart';

void main() {
  group('Tags', () {
    test('Entity serialization retains tags', () {
      final json = <String, Object?>{
        'uid': {'type': 'User', 'id': 'alice'},
        'parents': const <Object?>[],
        'attrs': <String, Object?>{},
        'tags': <String, Object?>{'department': 'eng'},
      };

      final entity = Entity.fromJson(json);
      expect(entity.tags['department'], equals(Value.string('eng')));
      expect(entity.toJson(), equals(json));

      final proto = entity.toProto();
      final roundTrip = Entity.fromProto(proto);
      expect(roundTrip, equals(entity));
    });

    test('Expr getTag roundtrips through json and proto', () {
      final exprJson = <String, Object?>{
        'getTag': {
          'left': {
            'Value': {
              '__entity': {'type': 'User', 'id': 'alice'},
            },
          },
          'tag': {'Value': 'department'},
        },
      };

      final expr = Expr.fromJson(exprJson);
      expect(expr, isA<ExprGetTag>());
      expect(expr.toJson(), equals(exprJson));

      final proto = expr.toProto();
      final fromProto = Expr.fromProto(proto);
      expect(fromProto, equals(expr));
    });

    test('Evaluator handles getTag and hasTag semantics', () {
      const userId = EntityUid.of('User', 'alice');
      final entity = Entity(
        uid: userId,
        tags: {'department': Value.string('eng')},
      );
      final context = EvaluationContext(
        entities: {userId: entity},
        principal: userId,
        action: const EntityUid.unknown(),
        resource: const EntityUid.unknown(),
        context: const RecordValue({}),
      );
      final evaluator = Evalutator(context);

      final getTagExpr = Expr.getTag(
        left: Expr.value(Value.entity(uid: userId)),
        tag: Expr.value(Value.string('department')),
      );
      expect(getTagExpr.accept(evaluator), equals(Value.string('eng')));

      final hasTagExpr = Expr.hasTag(
        left: Expr.value(Value.entity(uid: userId)),
        tag: Expr.value(Value.string('department')),
      );
      expect(hasTagExpr.accept(evaluator), equals(Value.bool(true)));

      final missingHasTagExpr = Expr.hasTag(
        left: Expr.value(Value.entity(uid: userId)),
        tag: Expr.value(Value.string('missing')),
      );
      expect(missingHasTagExpr.accept(evaluator), equals(Value.bool(false)));

      final missingGetTagExpr = Expr.getTag(
        left: Expr.value(Value.entity(uid: userId)),
        tag: Expr.value(Value.string('missing')),
      );
      expect(
        () => missingGetTagExpr.accept(evaluator),
        throwsA(isA<TagAccessException>()),
      );

      const missingUserId = EntityUid.of('User', 'bob');
      final missingGetTagEntityExpr = Expr.getTag(
        left: Expr.value(Value.entity(uid: missingUserId)),
        tag: Expr.value(Value.string('department')),
      );
      expect(
        () => missingGetTagEntityExpr.accept(evaluator),
        throwsA(isA<EntityNotFoundException>()),
      );

      final missingHasTagEntityExpr = Expr.hasTag(
        left: Expr.value(Value.entity(uid: missingUserId)),
        tag: Expr.value(Value.string('department')),
      );
      expect(
        missingHasTagEntityExpr.accept(evaluator),
        equals(Value.bool(false)),
      );

      final unspecifiedExpr = Expr.getTag(
        left: Expr.value(Value.entity(uid: const EntityUid.unknown())),
        tag: Expr.value(Value.string('department')),
      );
      expect(
        () => unspecifiedExpr.accept(evaluator),
        throwsA(isA<UnspecifiedEntityException>()),
      );
    });
  });
}
