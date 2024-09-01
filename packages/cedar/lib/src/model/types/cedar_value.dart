import 'package:cedar/ast.dart';
import 'package:cedar/src/util/pretty_json.dart';
import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';

part 'cedar_bool.dart';
part 'cedar_decimal.dart';
part 'cedar_entity_id.dart';
part 'cedar_extension.dart';
part 'cedar_ipaddr.dart';
part 'cedar_long.dart';
part 'cedar_record.dart';
part 'cedar_set.dart';
part 'cedar_slot.dart';
part 'cedar_string.dart';

@Deprecated('Use CedarValue instead')
typedef CedarValueJson = CedarValue;

sealed class CedarValue {
  const CedarValue();

  factory CedarValue.fromJson(Object? json) {
    return switch (json) {
      <String, Object?>{'__entity': _} ||
      <String, Object?>{'type': _, 'id': _} =>
        CedarEntityValue.fromJson(json),
      <String, Object?>{'__extn': _} => CedarExtensionCall.fromJson(json),
      final bool json => CedarBool.fromJson(json),
      final num json => CedarLong.fromJson(json.toInt()),
      final String json => CedarString.fromJson(json),
      final List json => CedarSet.fromJson(json),
      final Map json => CedarRecord.fromJson(json.cast()),
      _ => throw FormatException('Invalid Cedar JSON value: $json'),
    };
  }

  const factory CedarValue.entity({
    required CedarEntityId entityId,
  }) = CedarEntityValue;

  const factory CedarValue.extension({
    required String fn,
    required CedarValue arg,
  }) = CedarExtensionCall;

  const factory CedarValue.bool(bool value) = CedarBool;

  const factory CedarValue.long(int value) = CedarLong;

  const factory CedarValue.string(String value) = CedarString;

  const factory CedarValue.set(List<CedarValue> elements) = CedarSet;

  const factory CedarValue.record(Map<String, CedarValue> attributes) =
      CedarRecord;

  Object? toJson();

  @override
  String toString() => prettyJson(toJson());
}

sealed class CedarComponent {
  CedarExpr toExpr();
}
