import 'package:cedar/cedar.dart';

void main() {
  const policies = '''
// Policy 0: Any User can create a list and see what lists they own
permit (
    principal,
    action in [Action::"CreateList", Action::"GetLists"],
    resource == Application::"TinyTodo"
);

// Policy 1: A User can perform any action on a List they own
permit (principal, action, resource)
when { resource has owner && resource.owner == principal };
''';
  final policySet = PolicySet.parse(policies);

  final app = Entity(
    uid: EntityUid.of('Application', 'TinyTodo'),
  );
  final user = Entity(
    uid: EntityUid.of('User', 'alice'),
    parents: [app.uid],
    attributes: {
      'name': Value.string('Alice'),
    },
  );
  final canCreateTodo = policySet.isAuthorized(
    AuthorizationRequest(
      principal: user.uid,
      action: EntityUid.of('Action', 'CreateList'),
      resource: app.uid,
      entities: {app.uid: app, user.uid: user},
    ),
  );
  switch (canCreateTodo) {
    case AuthorizationResponse(decision: Decision.allow):
      print('Alice can create the todo list!');
    case AuthorizationResponse(
        :final errorMessages,
        :final reasons,
      ):
      print('Alice cannot create the todo list');
      print('Contributing policies: $reasons');
      print('Error messages: $errorMessages');
  }
}
