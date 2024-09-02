import 'package:cedar/cedar.dart';
import 'package:cedar_tests/corpus_tests.dart';
import 'package:test/test.dart';

void main() {
  group('Corpus', () {
    for (final CedarTest(
          :name,
          :schemaJson,
          :entitiesJson,
          :policiesCedar,
          :queries,
        ) in cedarCorpusTests.values) {
      group(name, () {
        late final CedarAuthorizer cedar;
        late final Map<EntityUid, Entity> entities;

        setUpAll(() {
          cedar = PolicySet.parse(policiesCedar);
          entities = Map.fromEntries(
            entitiesJson.map((json) {
              final entity = Entity.fromJson(
                json as Map<String, Object?>,
              );
              return MapEntry(entity.uid, entity);
            }),
          );
        });

        test('can parse schema', () {
          final schema = CedarSchema.fromJson(schemaJson);
          expect(schema.toJson(), equals(schemaJson));
        });

        test('can parse entities', () {
          final entities = entitiesJson
              .map((entity) => Entity.fromJson(entity as Map<String, Object?>))
              .toList();
          expect(entities.map((e) => e.toJson()), equals(entitiesJson));
        });

        for (final query in queries) {
          test(query.description, () {
            try {
              final response = cedar.isAuthorized(
                AuthorizationRequest(
                  entities: entities,
                  principal: query.principal,
                  action: query.action,
                  resource: query.resource,
                  context: query.context
                      .map((k, v) => MapEntry(k, Value.fromJson(v))),
                ),
              );
              expect(response.decision, query.decision);
              expect(
                response.errors.map((it) => it.policyId),
                orderedEquals(query.errors),
              );
              expect(response.reasons, query.reasons);
            } on UnsupportedError {
              if (!const bool.fromEnvironment('dart.library.io')) {
                // OK, some methods not implemented on web
                return;
              }
              rethrow;
            }
          });
        }
      });
    }
  });
}
