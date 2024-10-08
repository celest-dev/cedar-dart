import 'package:cedar/cedar.dart';
import 'package:cedar_ffi/cedar_ffi.dart';
import 'package:cedar_tests/corpus_tests.dart';
import 'package:test/test.dart';

void main() {
  group('Corpus', () {
    for (final CedarTest(
          :name,
          :schemaJson,
          :entitiesJson,
          :policiesCedar,
          :shouldValidate,
          :queries,
        ) in cedarCorpusTests.values) {
      group(name, () {
        late final CedarEngine cedar;

        setUpAll(() {
          cedar = CedarEngine(
            schema: CedarSchema.fromJson(schemaJson),
            entities: entitiesJson
                .map(
                  (entity) => Entity.fromJson(
                    entity as Map<String, Object?>,
                  ),
                )
                .toList(),
            policySet: CedarPolicySetFfi.fromCedar(policiesCedar),
            validate: shouldValidate,
            logLevel: CedarLogLevel.trace,
          );
          addTearDown(cedar.close);
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
            final response = cedar.isAuthorized(
              AuthorizationRequest(
                principal: query.principal,
                action: query.action,
                resource: query.resource,
                context:
                    query.context.map((k, v) => MapEntry(k, Value.fromJson(v))),
              ),
            );
            expect(response.decision, query.decision);
            expect(
              response.errors.map((it) => it.policyId),
              orderedEquals(query.errors),
            );
            expect(response.reasons, query.reasons);
          });
        }

        test('can parse policies', () {
          final rawPolicies = parsePolicies(policiesCedar);
          final rawStaticPolicies =
              rawPolicies['staticPolicies'] as Map? ?? const {};
          final policies = PolicySet.fromJson(rawPolicies).policies;
          for (final MapEntry(key: id, value: policy) in policies.entries) {
            expect(policy.toJson(), equals(rawStaticPolicies[id]));
          }
        });
      });
    }
  });
}
