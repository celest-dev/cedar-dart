import 'dart:convert';
import 'dart:ffi';

import 'package:cedar/cedar.dart';
import 'package:cedar_ffi/src/ffi/cedar_bindings.ffi.dart' as bindings;
import 'package:ffi/ffi.dart';

/// An FFI extension of [PolicySet].
extension type CedarPolicySetFfi._(PolicySet _policySet) implements PolicySet {
  /// Parses a set of Cedar policies from the given [policiesIdl].
  CedarPolicySetFfi.fromCedar(String policiesIdl)
      : _policySet = PolicySet.fromJson(parsePolicies(policiesIdl));
}

/// Parses a set of Cedar policies from the given [policiesIdl] using the
/// Cedar Rust engine via FFI.
Map<String, Object?> parsePolicies(String policiesIdl) {
  return using((arena) {
    final cPolicies = bindings.cedar_parse_policy_set(
      policiesIdl.toNativeUtf8(allocator: arena).cast(),
    );
    switch (cPolicies) {
      case bindings.CCedarPolicySetResult(:final errors, :final errors_len)
          when errors_len > 0:
        final errorStrings = <String>[];
        for (var i = 0; i < errors_len; i++) {
          errorStrings.add(errors[i].cast<Utf8>().toDartString());
        }
        throw FormatException(
          'Error parsing policies: '
          '${errorStrings.join(', ')}',
          policiesIdl,
        );
      case bindings.CCedarPolicySetResult(
          :final policy_set_json,
          :final policy_set_json_len,
        ):
        return jsonDecode(
          policy_set_json
              .cast<Utf8>()
              .toDartString(length: policy_set_json_len),
        ) as Map<String, Object?>;
    }
  });
}

extension CedarPolicyLinkFfi on Policy {
  Policy link(Map<SlotId, EntityUid> values) => using((arena) {
        final linkedPolicy = bindings.cedar_link_policy_template(
          jsonEncode(toJson()).toNativeUtf8(allocator: arena).cast(),
          jsonEncode(values.map((k, v) => MapEntry(k.toJson(), v.toString())))
              .toNativeUtf8(allocator: arena)
              .cast(),
        );
        if (linkedPolicy == nullptr) {
          throw FormatException('Could not link policy');
        }
        return Policy.fromJson(
          jsonDecode(linkedPolicy.cast<Utf8>().toDartString()),
        );
      });
}
