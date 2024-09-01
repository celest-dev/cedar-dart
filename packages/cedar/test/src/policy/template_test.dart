import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
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

        final policySet = CedarPolicySet.parse(principalTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = CedarPolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.principal,
          isA<CedarPrincipalEquals>()
              .having((it) => it.entity, 'entity', CedarSlotId.principal),
        );

        // final linkedPolicy = template.link(
        //   {CedarSlotId.principal: CedarEntityId('Test', 'test')},
        // );
        // expect(linkedPolicy.isTemplate, false);
        // expect(
        //     linkedPolicy.principal,
        //     isA<CedarPrincipalEquals>().having(
        //       (it) => it.entity,
        //       'entity',
        //       CedarEntityId('Test', 'test'),
        //     ));
      });

      test('in', () {
        const principalTemplate = '''
permit(
  principal in ?principal,
  action,
  resource
);
''';

        final policySet = CedarPolicySet.parse(principalTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = CedarPolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.principal,
          isA<CedarPrincipalIn>()
              .having((it) => it.entity, 'entity', CedarSlotId.principal),
        );

        // final linkedPolicy = template.link(
        //   {CedarSlotId.principal: CedarEntityId('Test', 'test')},
        // );
        // expect(linkedPolicy.isTemplate, false);
        // expect(
        //     linkedPolicy.principal,
        //     isA<CedarPrincipalIn>().having(
        //       (it) => it.entity,
        //       'entity',
        //       CedarEntityId('Test', 'test'),
        //     ));
      });

      test('isIn', () {
        const principalTemplate = '''
permit(
  principal is Test in ?principal,
  action,
  resource
);
''';

        final policySet = CedarPolicySet.parse(principalTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = CedarPolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.principal,
          isA<CedarPrincipalIsIn>()
              .having((it) => it.entityType, 'entityType', 'Test')
              .having((it) => it.entity, 'entity', CedarSlotId.principal),
        );

        // final linkedPolicy = template.link(
        //   {CedarSlotId.principal: CedarEntityId('Test', 'test')},
        // );
        // expect(linkedPolicy.isTemplate, false);
        // expect(
        //   linkedPolicy.principal,
        //   isA<CedarPrincipalIsIn>()
        //       .having(
        //           (it) => it.entity, 'entity', CedarEntityId('Test', 'test'))
        //       .having((it) => it.entityType, 'entityType', 'Test'),
        // );
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

        final policySet = CedarPolicySet.parse(resourceTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = CedarPolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.resource,
          isA<CedarResourceEquals>().having(
            (it) => it.entity,
            'entity',
            CedarSlotId.resource,
          ),
        );

        // final linkedPolicy = template.link(
        //   {CedarSlotId.resource: CedarEntityId('Test', 'test')},
        // );
        // expect(linkedPolicy.isTemplate, false);
        // expect(
        //   linkedPolicy.resource,
        //   isA<CedarResourceEquals>().having(
        //     (it) => it.entity,
        //     'entity',
        //     CedarEntityId('Test', 'test'),
        //   ),
        // );
      });
      test('in', () {
        const resourceTemplate = '''
permit(
  principal,
  action,
  resource in ?resource
);
''';

        final policySet = CedarPolicySet.parse(resourceTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = CedarPolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.resource,
          isA<CedarResourceIn>().having(
            (it) => it.entity,
            'entity',
            CedarSlotId.resource,
          ),
        );

        // final linkedPolicy = template.link(
        //   {CedarSlotId.resource: CedarEntityId('Test', 'test')},
        // );
        // expect(linkedPolicy.isTemplate, false);
        // expect(
        //   linkedPolicy.resource,
        //   isA<CedarResourceIn>().having(
        //     (it) => it.entity,
        //     'entity',
        //     CedarEntityId('Test', 'test'),
        //   ),
        // );
      });

      test('isIn', () {
        const resourceTemplate = '''
permit(
  principal,
  action,
  resource is Test in ?resource
);
''';

        final policySet = CedarPolicySet.parse(resourceTemplate);
        expect(policySet.templates, hasLength(1));

        final serded = CedarPolicySet.fromJson(policySet.toJson());
        expect(serded.templates, hasLength(1));

        final template = policySet.templates.values.first;
        expect(template.isTemplate, true);
        expect(
          template.resource,
          isA<CedarResourceIsIn>()
              .having((it) => it.entityType, 'entityType', 'Test')
              .having((it) => it.entity, 'entity', CedarSlotId.resource),
        );

        // final linkedPolicy = template.link(
        //   {CedarSlotId.resource: CedarEntityId('Test', 'test')},
        // );
        // expect(linkedPolicy.isTemplate, false);
        // expect(
        //   linkedPolicy.resource,
        //   isA<CedarResourceIsIn>()
        //       .having(
        //           (it) => it.entity, 'entity', CedarEntityId('Test', 'test'))
        //       .having((it) => it.entityType, 'entityType', 'Test'),
        // );
      });
    });
  });
}
