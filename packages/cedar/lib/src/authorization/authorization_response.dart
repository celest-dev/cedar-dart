import 'dart:collection';

import 'package:cedar/cedar.dart';
import 'package:cedar/src/parser/position.dart';
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
    AuthorizationDiagnostics? diagnostics,
    Iterable<AuthorizationReason>? reasons,
    Iterable<AuthorizationException>? errors,
  }) : diagnostics =
           diagnostics ??
           AuthorizationDiagnostics(
             reasons: reasons ?? const [],
             errors: errors ?? const [],
           );

  /// The decision of the authorization request.
  final Decision decision;

  /// Rich diagnostics associated with this decision.
  final AuthorizationDiagnostics diagnostics;

  /// The policy IDs of the policies that contributed to the decision.
  ///
  /// If no policies applied to the request, this will be empty.
  List<String> get reasons =>
      diagnostics.reasons.map((reason) => reason.policyId).toList();

  /// Any evaluation errors which occurred during the request.
  ///
  /// If no errors occurred, this will be empty.
  AuthorizationErrors get errors => diagnostics.errors;

  /// Any evaluation errors which occurred during the request.
  ///
  /// If no errors occurred, this will be empty.
  List<String> get errorMessages =>
      diagnostics.errors.map((it) => it.message).toList();
}

/// Detailed diagnostics for an authorization response.
final class AuthorizationDiagnostics {
  AuthorizationDiagnostics({
    Iterable<AuthorizationReason> reasons = const [],
    Iterable<AuthorizationException> errors = const [],
  }) : reasons = List.unmodifiable(reasons),
       errors = AuthorizationErrors(List.unmodifiable(errors));

  /// Reasons that contributed to the decision.
  final List<AuthorizationReason> reasons;

  /// Errors raised while evaluating policies.
  final AuthorizationErrors errors;
}

/// Metadata describing why a policy contributed to a decision.
final class AuthorizationReason {
  AuthorizationReason({
    required this.policyId,
    this.effect,
    Map<String, String>? annotations,
    this.position,
    this.templateId,
  }) : annotations = _immutableAnnotations(annotations);

  /// Identifier of the policy that matched.
  final String policyId;

  /// The effect of the policy when it was evaluated.
  final Effect? effect;

  /// Any annotations attached to the policy definition.
  final Map<String, String> annotations;

  /// The source location of the policy, when available.
  final Position? position;

  /// The template identifier, when this reason is derived from a template
  /// instantiation.
  final String? templateId;
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
  AuthorizationException({
    this.policyId,
    required this.message,
    this.category,
    Map<String, String>? annotations,
    this.position,
  }) : annotations = _nullableImmutableAnnotations(annotations);

  /// Deserializes a [AuthorizationException] from JSON.
  factory AuthorizationException.fromJson(Map<String, Object?> json) {
    return AuthorizationException(
      policyId: json['policy_id'] as String?,
      message: json['message'] as String,
      category: _categoryFromJson(json['category']),
      annotations: json['annotations'] is Map
          ? Map.unmodifiable(
              (json['annotations'] as Map).map(
                (key, value) => MapEntry('$key', value == null ? '' : '$value'),
              ),
            )
          : null,
      position: json['position'] is Map<String, Object?>
          ? Position.fromJson(json['position']! as Map<String, Object?>)
          : null,
    );
  }

  /// The ID of the policy which caused the error.
  final String? policyId;

  /// The error message.
  final String message;

  /// The high-level category of the error.
  final AuthorizationErrorCategory? category;

  /// Any annotations attached to the offending policy.
  final Map<String, String>? annotations;

  /// Where in the policy source the error originated, when available.
  final Position? position;

  @override
  String toString() {
    final buf = StringBuffer('Authorization error: $message');
    if (policyId != null) {
      buf.write(' (policy=$policyId)');
    }
    if (category != null) {
      buf.write(' [category=${category!.name}]');
    }
    return buf.toString();
  }
}

/// Broad categories describing authorization failures.
enum AuthorizationErrorCategory {
  @JsonValue('evaluation')
  evaluation,

  @JsonValue('linking')
  linking,

  @JsonValue('internal')
  internal,
}

AuthorizationErrorCategory? _categoryFromJson(Object? raw) {
  if (raw is String && raw.isNotEmpty) {
    for (final category in AuthorizationErrorCategory.values) {
      if (category.name == raw) {
        return category;
      }
    }
  }
  return null;
}

Map<String, String> _immutableAnnotations(Map<String, String>? annotations) {
  if (annotations == null || annotations.isEmpty) {
    return const {};
  }
  return Map.unmodifiable(Map.of(annotations));
}

Map<String, String>? _nullableImmutableAnnotations(
  Map<String, String>? annotations,
) {
  if (annotations == null || annotations.isEmpty) {
    return null;
  }
  return Map.unmodifiable(Map.of(annotations));
}
