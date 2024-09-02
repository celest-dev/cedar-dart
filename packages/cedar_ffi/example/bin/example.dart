import 'dart:convert';
import 'dart:io';

import 'package:cedar/cedar.dart';
import 'package:cedar_ffi/cedar_ffi.dart';

Future<void> main() async {
  final root = Platform.script.resolve('cedar/');
  final schemaJson =
      File.fromUri(root.resolve('example.cedarschema.json')).readAsStringSync();
  final policiesCedar =
      File.fromUri(root.resolve('example.cedar')).readAsStringSync();

  final cedar = CedarEngine(
    schema: CedarSchema.fromJson(
      jsonDecode(schemaJson) as Map<String, Object?>,
    ),
    policySet: CedarPolicySetFfi.fromCedar(policiesCedar),
  );

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
  final canCreateTodo = cedar.isAuthorized(
    AuthorizationRequest(
      principal: user.uid,
      action: EntityUid.of('Action', 'CreateList'),
      resource: app.uid,
    ),
    entities: [app, user],
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
