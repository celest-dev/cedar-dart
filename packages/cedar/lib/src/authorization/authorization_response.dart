import 'dart:collection';

import 'package:cedar/cedar.dart';
import 'package:json_annotation/json_annotation.dart';

/// The decision of an authorization request.
enum Decision {
  @JsonValue('Allow')
  allow,

  @JsonValue('Deny')
  deny,
}

/// {@template cedar.cedar_authorization_response}
/// The response to a [CedarAuthorizer] request.
/// {@endtemplate}
final class AuthorizationResponse {
  /// {@macro cedar.cedar_authorization_response}
  AuthorizationResponse({
    required this.decision,
    List<String>? reasons,
    Iterable<AuthorizationException>? errors,
  })  : reasons = reasons ?? const [],
        errors = AuthorizationErrors(errors ?? const []);

  /// The decision of the authorization request.
  final Decision decision;

  /// The policy IDs of the policies that contributed to the decision.
  ///
  /// If no policies applied to the request, this will be empty.
  final List<String> reasons;

  /// Any evaluation errors which occurred during the request.
  ///
  /// If no errors occurred, this will be empty.
  final AuthorizationErrors errors;

  /// Any evaluation errors which occurred during the request.
  ///
  /// If no errors occurred, this will be empty.
  List<String> get errorMessages => errors.map((it) => it.message).toList();
}

/// {@template cedar.cedar_authorization_errors}
/// The errors which caused a [Decision.deny].
/// {@endtemplate}
final class AuthorizationErrors
    extends UnmodifiableListView<AuthorizationException> {
  /// {@macro cedar.cedar_authorization_errors}
  AuthorizationErrors(super.source);

  @override
  String toString() {
    final buf = StringBuffer()..writeln('Authorization errors: ');
    for (final error in this) {
      buf.write('  - ${error.message}');
      if (error.policyId case final policyId?) {
        buf.write(' (policy=$policyId)');
      }
      buf.writeln();
    }
    return buf.toString();
  }
}

/// {@template cedar.cedar_authorization_error}
/// An error in approving a [AuthorizationRequest], including potentially
/// the [policyId] which caused the error.
/// {@endtemplate}
final class AuthorizationException implements CedarException {
  /// {@macro cedar.cedar_authorization_error}
  const AuthorizationException({
    this.policyId,
    required this.message,
  });

  /// Deserializes a [AuthorizationException] from JSON.
  factory AuthorizationException.fromJson(Map<String, Object?> json) {
    return AuthorizationException(
      policyId: json['policy_id'] as String?,
      message: json['message'] as String,
    );
  }

  /// The ID of the policy which caused the error.
  final String? policyId;

  /// The error message.
  final String message;

  @override
  String toString() {
    final buf = StringBuffer('Authorization error: $message');
    if (policyId != null) {
      buf.write(' (policy=$policyId)');
    }
    return buf.toString();
  }
}
