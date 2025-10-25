import 'package:cedar/ast.dart' show Annotations, Position;
import 'package:cedar/cedar.dart';
import 'package:test/test.dart';

void main() {
  group('PolicySet diagnostics', () {
    test('captures static policy metadata', () {
      final policy = Policy(
        effect: Effect.permit,
        annotations: Annotations({'id': 'allow-principal'}),
        position: Position(
          filename: Uri.parse('file:///policies.cedar'),
          offset: 0,
          line: 1,
          column: 1,
        ),
        principal: const PrincipalAll(),
        action: const ActionAll(),
        resource: const ResourceAll(),
      );

      final policySet = PolicySet(policies: {'allow-principal': policy});
      final request = AuthorizationRequest(
        principal: EntityUid.of('User', 'alice'),
        action: EntityUid.of('Action', 'view'),
        resource: EntityUid.of('Photo', 'door'),
      );

      final response = policySet.isAuthorized(request);
      expect(response.decision, Decision.allow);
      final reason = response.diagnostics.reasons.single;
      expect(reason.policyId, 'allow-principal');
      expect(reason.annotations['id'], 'allow-principal');
      expect(reason.effect, Effect.permit);
      expect(reason.position?.line, 1);
      expect(response.errors, isEmpty);
    });
  });
}
