import 'package:cedar/ast.dart';
import 'package:cedar/src/proto/cedar/v3/entity_uid.pb.dart' as pb;
import 'package:cedar/src/proto/cedar/v3/expr.pb.dart' as pb;
import 'package:cedar/src/proto/cedar/v3/value.pb.dart' as pb;
import 'package:cedar/src/proto/google/protobuf/wrappers.pb.dart' as pb;
import 'package:cedar/src/util/pretty_json.dart';
import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:fixnum/fixnum.dart';

part 'entity_id.dart';
part 'value/bool_value.dart';
part 'value/decimal_value.dart';
part 'value/entity_value.dart';
part 'value/extension_call.dart';
part 'value/long_value.dart';
part 'value/record_value.dart';
part 'value/set_value.dart';
part 'value/slot_id.dart';
part 'value/string_value.dart';

sealed class Value {
  const Value();

  factory Value.fromJson(Object? json) {
    return switch (json) {
      <String, Object?>{'__entity': _} ||
      <String, Object?>{'type': _, 'id': _} =>
        EntityValue.fromJson(json),
      <String, Object?>{'__extn': _} => ExtensionCall.fromJson(json),
      final bool json => BoolValue.fromJson(json),
      final num json => LongValue.fromJson(json.toInt()),
      final String json => StringValue.fromJson(json),
      final List json => SetValue.fromJson(json),
      final Map json => RecordValue.fromJson(json.cast()),
      _ => throw FormatException('Invalid Cedar JSON value: $json'),
    };
  }

  factory Value.fromProto(pb.Value value) {
    return switch (value.whichValue()) {
      pb.Value_Value.entity => EntityValue.fromProto(value.entity),
      pb.Value_Value.extensionCall =>
        ExtensionCall.fromProto(value.extensionCall),
      pb.Value_Value.bool_3 => BoolValue.fromProto(value.bool_3),
      pb.Value_Value.long => LongValue.fromProto(value.long),
      pb.Value_Value.string => StringValue.fromProto(value.string),
      pb.Value_Value.set => SetValue.fromProto(value.set),
      pb.Value_Value.record => RecordValue.fromProto(value.record),
      pb.Value_Value.decimal => DecimalValue.fromProto(value.decimal),
      final unknown => throw FormatException('Invalid Cedar value: $unknown'),
    };
  }

  const factory Value.entity({
    required EntityUid uid,
  }) = EntityValue;

  const factory Value.extensionCall({
    required String fn,
    required Value arg,
  }) = ExtensionCall;

  const factory Value.bool(bool value) = BoolValue;

  factory Value.integer(int value) = LongValue.fromInt;

  const factory Value.long(Int64 value) = LongValue;

  const factory Value.string(String value) = StringValue;

  const factory Value.set(List<Value> elements) = SetValue;

  const factory Value.record(Map<String, Value> attributes) = RecordValue;

  Object? toJson();
  pb.Value toProto();

  @override
  String toString() => prettyJson(toJson());
}

sealed class Component {
  Expr toExpr();
}
