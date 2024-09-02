import 'package:cedar/cedar.dart';
import 'package:cedar_ffi/cedar_ffi.dart';
import 'package:test/test.dart';

void main() {
  group('templates', () {
    group('principal', () {
      test('==', () {
        const principalTemplate = '''
permit(
  principal == ?principal,
  action,
  resource
);
''';

        final policySet = CedarPolicySetFfi.fromCedar(principalTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = PolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.principal,
          isA<PrincipalEquals>()
              .having((it) => it.entity, 'entity', SlotId.principal),
        );

        final linkedPolicy = template.link(
          {SlotId.principal: EntityUid.of('Test', 'test')},
        );
        expect(linkedPolicy.isTemplate, false);
        expect(
            linkedPolicy.principal,
            isA<PrincipalEquals>().having(
              (it) => it.entity,
              'entity',
              EntityValue(uid: EntityUid.of('Test', 'test')),
            ));
      });

      test('in', () {
        const principalTemplate = '''
permit(
  principal in ?principal,
  action,
  resource
);
''';

        final policySet = CedarPolicySetFfi.fromCedar(principalTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = PolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.principal,
          isA<PrincipalIn>()
              .having((it) => it.entity, 'entity', SlotId.principal),
        );

        final linkedPolicy = template.link(
          {SlotId.principal: EntityUid.of('Test', 'test')},
        );
        expect(linkedPolicy.isTemplate, false);
        expect(
            linkedPolicy.principal,
            isA<PrincipalIn>().having(
              (it) => it.entity,
              'entity',
              EntityValue(uid: EntityUid.of('Test', 'test')),
            ));
      });

      test('isIn', () {
        const principalTemplate = '''
permit(
  principal is Test in ?principal,
  action,
  resource
);
''';

        final policySet = CedarPolicySetFfi.fromCedar(principalTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = PolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.principal,
          isA<PrincipalIsIn>()
              .having((it) => it.entityType, 'entityType', 'Test')
              .having((it) => it.entity, 'entity', SlotId.principal),
        );

        final linkedPolicy = template.link(
          {SlotId.principal: EntityUid.of('Test', 'test')},
        );
        expect(linkedPolicy.isTemplate, false);
        expect(
          linkedPolicy.principal,
          isA<PrincipalIsIn>()
              .having(
                (it) => it.entity,
                'entity',
                EntityValue(uid: EntityUid.of('Test', 'test')),
              )
              .having((it) => it.entityType, 'entityType', 'Test'),
        );
      });
    });

    group('resource', () {
      test('==', () {
        const resourceTemplate = '''
permit(
  principal,
  action,
  resource == ?resource
);
''';

        final policySet = CedarPolicySetFfi.fromCedar(resourceTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = PolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.resource,
          isA<ResourceEquals>().having(
            (it) => it.entity,
            'entity',
            SlotId.resource,
          ),
        );

        final linkedPolicy = template.link(
          {SlotId.resource: EntityUid.of('Test', 'test')},
        );
        expect(linkedPolicy.isTemplate, false);
        expect(
          linkedPolicy.resource,
          isA<ResourceEquals>().having(
            (it) => it.entity,
            'entity',
            EntityValue(uid: EntityUid.of('Test', 'test')),
          ),
        );
      });
      test('in', () {
        const resourceTemplate = '''
permit(
  principal,
  action,
  resource in ?resource
);
''';

        final policySet = CedarPolicySetFfi.fromCedar(resourceTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = PolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.resource,
          isA<ResourceIn>().having(
            (it) => it.entity,
            'entity',
            SlotId.resource,
          ),
        );

        final linkedPolicy = template.link(
          {SlotId.resource: EntityUid.of('Test', 'test')},
        );
        expect(linkedPolicy.isTemplate, false);
        expect(
          linkedPolicy.resource,
          isA<ResourceIn>().having(
            (it) => it.entity,
            'entity',
            EntityValue(uid: EntityUid.of('Test', 'test')),
          ),
        );
      });

      test('isIn', () {
        const resourceTemplate = '''
permit(
  principal,
  action,
  resource is Test in ?resource
);
''';

        final policySet = CedarPolicySetFfi.fromCedar(resourceTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = PolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.resource,
          isA<ResourceIsIn>()
              .having((it) => it.entityType, 'entityType', 'Test')
              .having((it) => it.entity, 'entity', SlotId.resource),
        );

        final linkedPolicy = template.link(
          {SlotId.resource: EntityUid.of('Test', 'test')},
        );
        expect(linkedPolicy.isTemplate, false);
        expect(
          linkedPolicy.resource,
          isA<ResourceIsIn>()
              .having(
                (it) => it.entity,
                'entity',
                EntityValue(uid: EntityUid.of('Test', 'test')),
              )
              .having((it) => it.entityType, 'entityType', 'Test'),
        );
      });
    });
  });
}
