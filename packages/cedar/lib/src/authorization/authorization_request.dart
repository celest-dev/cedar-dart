import 'package:cedar/cedar.dart';

/// {@template cedar.cedar_authorization_request}
/// A request for authorization to a [CedarEngine].
/// {@endtemplate}
final class AuthorizationRequest {
  /// {@macro cedar.cedar_authorization_request}
  const AuthorizationRequest({
    this.entities = const {},
    this.principal,
    this.action,
    this.resource,
    this.context,
  });

  /// The entities in the request.
  final Map<EntityUid, Entity> entities;

  /// The principal component of the request.
  final EntityUid? principal;

  /// The action component of the request.
  final EntityUid? action;

  /// The resource component of the request.
  final EntityUid? resource;

  /// The context of the request.
  final Map<String, Value>? context;
}
