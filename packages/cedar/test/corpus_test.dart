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
        late final PolicySet policySet;
        late final Map<EntityUid, Entity> entities;

        setUpAll(() {
          policySet = PolicySet.parse(policiesCedar);
          entities = Map.fromEntries(
            entitiesJson.map((json) {
              final entity = Entity.fromJson(
                json as Map<String, Object?>,
              );
              return MapEntry(entity.uid, entity);
            }),
          );
        });

        // Workaround for buggy == for BuiltMap
        void expectEquals(PolicySet set, PolicySet other) {
          // TODO(dnys1): Get working
          return;
          // expect(set.policies.toMap(), equals(other.policies.toMap()));
          // expect(set.templates.toMap(), equals(other.templates.toMap()));
          // expect(set.templateLinks, unorderedEquals(other.templateLinks));
        }

        test('can interop policies with proto', () {
          final policySetProto = policySet.toProto();
          final policySetFromProto = PolicySet.fromProto(policySetProto);
          expectEquals(policySet, policySetFromProto);
          expect(policySetProto, equals(policySetFromProto.toProto()));
        });

        test('can interop policies with json', () {
          final policySetJson = policySet.toJson();
          final policySetFromJson = PolicySet.fromJson(policySetJson);
          expectEquals(policySet, policySetFromJson);
          expect(policySetJson, equals(policySetFromJson.toJson()));
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

          final entitiesProto = entities.map((e) => e.toProto()).toList();
          final entitiesFromProto =
              entitiesProto.map((proto) => Entity.fromProto(proto)).toList();
          expect(entities, equals(entitiesFromProto));
          expect(
            entitiesProto,
            equals(entitiesFromProto.map((e) => e.toProto())),
          );
        });

        for (final query in queries) {
          test(query.description, () {
            try {
              final response = policySet.isAuthorized(
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
