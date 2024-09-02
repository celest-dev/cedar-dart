import 'package:cedar/cedar.dart';

abstract interface class CedarAuthorizer {
  /// Responds to an authorization [request].
  AuthorizationResponse isAuthorized(
    AuthorizationRequest request,
  );
}
