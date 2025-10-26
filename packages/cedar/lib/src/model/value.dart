import 'package:cedar/ast.dart';
import 'package:cedar/src/proto/cedar/v4/entity.pb.dart' as pb;
import 'package:cedar/src/proto/cedar/v4/entity_uid.pb.dart' as pb;
import 'package:cedar/src/proto/cedar/v4/expr.pb.dart' as pb;
import 'package:cedar/src/proto/cedar/v4/value.pb.dart' as pb;
import 'package:cedar/src/proto/google/protobuf/wrappers.pb.dart' as pb;
import 'package:cedar/src/util/ip_parsing.dart';
import 'package:cedar/src/util/pretty_json.dart';
import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:fixnum/fixnum.dart';

part 'entity.dart';
part 'entity_id.dart';
part 'value/bool_value.dart';
part 'value/datetime_value.dart';
part 'value/decimal_value.dart';
part 'value/duration_value.dart';
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
      <String, Object?>{'type': _, 'id': _} => EntityValue.fromJson(json),
      <String, Object?>{'__extn': final Map<String, Object?> extn} =>
        _valueFromExtensionJson(extn),
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
      pb.Value_Value.extensionCall => _valueFromExtensionProto(
        value.extensionCall,
      ),
      pb.Value_Value.bool_3 => BoolValue.fromProto(value.bool_3),
      pb.Value_Value.long => LongValue.fromProto(value.long),
      pb.Value_Value.string => StringValue.fromProto(value.string),
      pb.Value_Value.set => SetValue.fromProto(value.set),
      pb.Value_Value.record => RecordValue.fromProto(value.record),
      pb.Value_Value.decimal => DecimalValue.fromProto(value.decimal),
      final unknown => throw FormatException('Invalid Cedar value: $unknown'),
    };
  }

  const factory Value.entity({required EntityUid uid}) = EntityValue;

  const factory Value.extensionCall({required String fn, required Value arg}) =
      ExtensionCall;

  const factory Value.bool(bool value) = BoolValue;

  factory Value.integer(int value) = LongValue.fromInt;

  const factory Value.long(Int64 value) = LongValue;

  const factory Value.string(String value) = StringValue;

  const factory Value.set(List<Value> elements) = SetValue;

  const factory Value.record(Map<String, Value> attributes) = RecordValue;

  const factory Value.datetime(Int64 milliseconds) = DatetimeValue;

  const factory Value.duration(Int64 milliseconds) = DurationValue;

  Object? toJson();
  pb.Value toProto();

  @override
  String toString() => prettyJson(toJson());
}

Value _valueFromExtensionJson(Map<String, Object?> extn) {
  final fn = extn['fn'];
  final arg = extn['arg'];
  if (fn is! String) {
    throw FormatException('Invalid Cedar extension call: $extn');
  }
  switch (fn) {
    case 'datetime':
      if (arg is! String) {
        throw FormatException('Invalid datetime argument: $arg');
      }
      return DatetimeValue.parse(arg);
    case 'duration':
      if (arg is! String) {
        throw FormatException('Invalid duration argument: $arg');
      }
      return DurationValue.parse(arg);
    case 'decimal':
      if (arg is! String) {
        throw FormatException('Invalid decimal argument: $arg');
      }
      return DecimalValue.parse(arg);
    case 'ip':
      if (arg is! String) {
        throw FormatException('Invalid ip argument: $arg');
      }
      if (arg.codeUnits.any((codeUnit) => codeUnit == 0)) {
        throw FormatException('IP literal cannot contain null bytes');
      }
      try {
        final parsed = ParsedIp.parse(arg);
        return StringValue(
          parsed.toCanonicalString(),
          extensionJson: {
            '__extn': {'fn': 'ip', 'arg': arg},
          },
        );
      } on ArgumentError catch (error) {
        throw FormatException(error.message ?? error.toString());
      }
    case 'offset':
      final args = _parseExtensionArgs(extn, fn, expectedLength: 2);
      final base = args[0];
      final duration = args[1];
      if (base is! DatetimeValue || duration is! DurationValue) {
        throw FormatException('Invalid offset arguments: ${extn['args']}');
      }
      return base.offset(duration);
    case 'durationSince':
      final args = _parseExtensionArgs(extn, fn, expectedLength: 2);
      final lhs = args[0];
      final rhs = args[1];
      if (lhs is! DatetimeValue || rhs is! DatetimeValue) {
        throw FormatException(
          'Invalid durationSince arguments: ${extn['args']}',
        );
      }
      return lhs.durationSince(rhs);
    case 'toDate':
      final args = _parseExtensionArgs(extn, fn, expectedLength: 1);
      final datetime = args.first;
      if (datetime is! DatetimeValue) {
        throw FormatException('Invalid toDate arguments: ${extn['args']}');
      }
      return datetime.toDate();
    case 'toTime':
      final args = _parseExtensionArgs(extn, fn, expectedLength: 1);
      final datetime = args.first;
      if (datetime is! DatetimeValue) {
        throw FormatException('Invalid toTime arguments: ${extn['args']}');
      }
      return datetime.toTime();
    default:
      return ExtensionCall(fn: fn, arg: Value.fromJson(arg));
  }
}

List<Value> _parseExtensionArgs(
  Map<String, Object?> extn,
  String fn, {
  int? expectedLength,
}) {
  final Object? rawArgs = extn['args'];
  if (rawArgs is! List<Object?>) {
    throw FormatException('Invalid arguments for $fn: ${extn['args']}');
  }
  final args = [for (final element in rawArgs) Value.fromJson(element)];
  if (expectedLength != null && args.length != expectedLength) {
    throw FormatException(
      'Invalid number of arguments for $fn: expected $expectedLength, got ${args.length}',
    );
  }
  return args;
}

Value _valueFromExtensionProto(pb.ExtensionCall extensionCall) {
  final fn = extensionCall.fn;
  switch (fn) {
    case 'datetime':
      final arg = Value.fromProto(extensionCall.arg);
      if (arg is! StringValue) {
        throw FormatException(
          'Invalid datetime argument: ${extensionCall.arg}',
        );
      }
      return DatetimeValue.parse(arg.value);
    case 'duration':
      final arg = Value.fromProto(extensionCall.arg);
      if (arg is! StringValue) {
        throw FormatException(
          'Invalid duration argument: ${extensionCall.arg}',
        );
      }
      return DurationValue.parse(arg.value);
    default:
      return ExtensionCall.fromProto(extensionCall);
  }
}

sealed class Component {
  Expr toExpr();
}

extension ComponentUid on Component {
  /// Returns the unique identifier for this component.
  ///
  /// Throws a [StateError] if this is a [SlotId].
  EntityUid get uid => switch (this) {
    final EntityUid uid || EntityValue(:final uid) || Entity(:final uid) => uid,
    SlotId() => throw StateError('Slot IDs do not have UIDs'),
  };
}
