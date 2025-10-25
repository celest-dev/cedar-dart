import 'package:cedar/cedar.dart';
import 'package:test/test.dart';

void main() {
  group('PolicySet template links', () {
    test('evaluates permit template links', () {
      final template = Policy.parse(
        'permit(principal == ?principal, action, resource);',
      );
      final policySet = PolicySet(
        templates: {'template': template},
        templateLinks: [
          TemplateLink(
            templateId: 'template',
            newId: 'link',
            values: {SlotId.principal: EntityUid.of('User', 'alice')},
          ),
        ],
      );

      final request = AuthorizationRequest(
        principal: EntityUid.of('User', 'alice'),
        action: EntityUid.of('Action', 'view'),
        resource: EntityUid.of('Photo', 'door'),
      );

      final response = policySet.isAuthorized(request);
      expect(response.decision, Decision.allow);
      expect(response.reasons, contains('link'));
      expect(response.reasons.length, equals(1));
      expect(response.errors, isEmpty);

      final reason = response.diagnostics.reasons.single;
      expect(reason.policyId, 'link');
      expect(reason.effect, Effect.permit);
      expect(reason.templateId, 'template');
      expect(reason.annotations, containsPair('templateId', 'template'));
    });

    test('reports missing template bindings', () {
      final template = Policy.parse(
        'permit(principal == ?principal, action, resource);',
      );
      final policySet = PolicySet(
        templates: {'template': template},
        templateLinks: [
          TemplateLink(
            templateId: 'template',
            newId: 'missing-binding',
            values: <SlotId, EntityUid>{},
          ),
        ],
      );

      final request = AuthorizationRequest(
        principal: EntityUid.of('User', 'alice'),
        action: EntityUid.of('Action', 'view'),
        resource: EntityUid.of('Photo', 'door'),
      );

      final response = policySet.isAuthorized(request);
      expect(response.decision, Decision.deny);
      expect(response.reasons, isEmpty);
      expect(response.errors.length, equals(1));
      expect(response.errors.single.policyId, 'missing-binding');
      expect(
        response.errors.single.message,
        'Invalid template link for template `template`: missing values for ?principal',
      );
      expect(
        response.errors.single.category,
        AuthorizationErrorCategory.linking,
      );
      expect(
        response.errors.single.annotations,
        containsPair('templateId', 'template'),
      );
    });

    test('reports unexpected template bindings', () {
      final template = Policy.parse(
        'permit(principal == ?principal, action, resource);',
      );
      final policySet = PolicySet(
        templates: {'template': template},
        templateLinks: [
          TemplateLink(
            templateId: 'template',
            newId: 'extra-binding',
            values: {
              SlotId.principal: EntityUid.of('User', 'alice'),
              SlotId.resource: EntityUid.of('Photo', 'door'),
            },
          ),
        ],
      );

      final request = AuthorizationRequest(
        principal: EntityUid.of('User', 'alice'),
        action: EntityUid.of('Action', 'view'),
        resource: EntityUid.of('Photo', 'door'),
      );

      final response = policySet.isAuthorized(request);
      expect(response.decision, Decision.deny);
      expect(response.reasons, isEmpty);
      expect(response.errors.length, equals(1));
      expect(response.errors.single.policyId, 'extra-binding');
      expect(
        response.errors.single.message,
        'Invalid template link for template `template`: unexpected bindings for ?resource',
      );
      expect(
        response.errors.single.category,
        AuthorizationErrorCategory.linking,
      );
      expect(
        response.errors.single.annotations,
        containsPair('templateId', 'template'),
      );
    });

    test('reports missing template definitions', () {
      final policySet = PolicySet(
        templateLinks: [
          TemplateLink(
            templateId: 'missing-template',
            newId: 'link',
            values: {SlotId.principal: EntityUid.of('User', 'alice')},
          ),
        ],
      );

      final request = AuthorizationRequest(
        principal: EntityUid.of('User', 'alice'),
        action: EntityUid.of('Action', 'view'),
        resource: EntityUid.of('Photo', 'door'),
      );

      final response = policySet.isAuthorized(request);
      expect(response.decision, Decision.deny);
      expect(response.reasons, isEmpty);
      expect(response.errors.length, equals(1));
      expect(response.errors.single.policyId, 'link');
      expect(
        response.errors.single.message,
        'Template `missing-template` not found for link `link`',
      );
      expect(
        response.errors.single.category,
        AuthorizationErrorCategory.linking,
      );
      expect(
        response.errors.single.annotations,
        containsPair('templateId', 'missing-template'),
      );
    });

    test('evaluates forbid template links as deny', () {
      final template = Policy.parse(
        'forbid(principal == ?principal, action, resource);',
      );
      final policySet = PolicySet(
        templates: {'template': template},
        templateLinks: [
          TemplateLink(
            templateId: 'template',
            newId: 'forbid-link',
            values: {SlotId.principal: EntityUid.of('User', 'alice')},
          ),
        ],
      );

      final request = AuthorizationRequest(
        principal: EntityUid.of('User', 'alice'),
        action: EntityUid.of('Action', 'view'),
        resource: EntityUid.of('Photo', 'door'),
      );

      final response = policySet.isAuthorized(request);
      expect(response.decision, Decision.deny);
      expect(response.reasons, contains('forbid-link'));
      expect(response.errors, isEmpty);

      final reason = response.diagnostics.reasons.single;
      expect(reason.effect, Effect.forbid);
      expect(reason.templateId, 'template');
    });
  });
}
