import 'dart:convert';
import 'dart:ffi';

import 'package:cedar/cedar.dart';
import 'package:cedar_ffi/src/ffi/cedar_bindings.ffi.dart' as bindings;
import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

enum CedarLogLevel {
  off,
  error,
  warn,
  info,
  debug,
  trace,
}

final class CedarEngine implements CedarAuthorizer, Finalizable {
  factory CedarEngine({
    required CedarSchema schema,
    List<Entity>? entities,
    PolicySet? policySet,
    CedarLogLevel logLevel = CedarLogLevel.off,
    @visibleForTesting bool validate = true,
  }) {
    final storeRef = using((arena) {
      final config = arena<bindings.CCedarConfig>();
      config.ref
        ..schema_json =
            jsonEncode(schema.toJson()).toNativeUtf8(allocator: arena).cast()
        ..policies_json = switch (policySet) {
          final policies? =>
            jsonEncode(policies.toJson()).toNativeUtf8(allocator: arena).cast(),
          null => nullptr,
        }
        ..entities_json = switch (entities) {
          final entities? =>
            jsonEncode(entities.map((e) => e.toJson()).toList())
                .toNativeUtf8(allocator: arena)
                .cast(),
          null => nullptr,
        }
        ..validate = validate
        ..log_level = logLevel.name.toNativeUtf8(allocator: arena).cast();
      final initResult = bindings.cedar_init(config);
      if (initResult.error != nullptr) {
        throw StateError(
          'Error initializing Cedar: '
          '${initResult.error.cast<Utf8>().toDartString(length: initResult.error_len)}',
        );
      }
      assert(
        initResult.store != nullptr,
        'Should be non-null when errors is null',
      );
      return initResult.store;
    });
    final engine = CedarEngine._(ref: storeRef);
    _finalizer.attach(engine, storeRef, detach: engine);
    return engine;
  }

  CedarEngine._({
    required Pointer<bindings.CedarStore> ref,
  }) : _ref = ref;

  static final Finalizer<Pointer<bindings.CedarStore>> _finalizer = Finalizer(
    bindings.cedar_deinit,
  );

  var _closed = false;

  final Pointer<bindings.CedarStore> _ref;

  @override
  AuthorizationResponse isAuthorized(
    AuthorizationRequest request, {
    List<Entity>? entities,
    PolicySet? policies,
  }) {
    if (_closed) {
      throw StateError('Cedar engine is closed');
    }
    return using((arena) {
      final query = arena<bindings.CCedarQuery>();
      query.ref
        ..principal_str = switch (request.principal) {
          final principal? => principal.normalized
              .toString()
              .toNativeUtf8(allocator: arena)
              .cast(),
          null => nullptr,
        }
        ..resource_str = switch (request.resource) {
          final resource? => resource.normalized
              .toString()
              .toNativeUtf8(allocator: arena)
              .cast(),
          null => nullptr,
        }
        ..action_str = switch (request.action) {
          final action? =>
            action.normalized.toString().toNativeUtf8(allocator: arena).cast(),
          null => nullptr,
        }
        ..context_json = switch (request.context) {
          final context? =>
            jsonEncode(context).toNativeUtf8(allocator: arena).cast(),
          null => nullptr,
        }
        ..entities_json = switch (entities) {
          final entities? =>
            jsonEncode(entities.map((e) => e.toJson()).toList())
                .toNativeUtf8(allocator: arena)
                .cast(),
          null => nullptr,
        }
        ..policies_json = switch (policies) {
          final policies? =>
            jsonEncode(policies.toJson()).toNativeUtf8(allocator: arena).cast(),
          null => nullptr,
        };
      final cDecision = bindings.cedar_is_authorized(_ref, query);
      return switch (cDecision) {
        bindings.CAuthorizationDecision(
          :final completion_error,
          :final completion_error_len
        )
            when completion_error != nullptr =>
          throw Exception(
            'Error performing authorization: '
            '${completion_error.cast<Utf8>().toDartString(length: completion_error_len)}',
          ),
        bindings.CAuthorizationDecision(
          :final is_authorized,
          :final reasons_json,
          :final reasons_json_len,
          :final errors_json,
          :final errors_json_len,
        ) =>
          AuthorizationResponse(
            decision: switch (is_authorized) {
              true => Decision.allow,
              false => Decision.deny,
            },
            reasons: reasons_json == nullptr
                ? const []
                : (jsonDecode(
                    reasons_json
                        .cast<Utf8>()
                        .toDartString(length: reasons_json_len),
                  ) as List)
                    .cast<String>(),
            errors: errors_json == nullptr
                ? const []
                : () {
                    final json = jsonDecode(
                      errors_json
                          .cast<Utf8>()
                          .toDartString(length: errors_json_len),
                    ) as List;
                    return json.cast<Map>().map(
                        (it) => AuthorizationException.fromJson(it.cast()));
                  }(),
          ),
      };
    });
  }

  /// Closes the Cedar engine.
  ///
  /// This should be called when the Cedar engine is no longer needed. After
  /// this method is called, the Cedar engine is no longer usable.
  void close() {
    if (_closed) {
      return;
    }
    _closed = true;
    _finalizer.detach(this);
    bindings.cedar_deinit(_ref);
  }
}
