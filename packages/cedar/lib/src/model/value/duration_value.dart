part of '../value.dart';

final class DurationValue extends Value {
  const DurationValue(this.milliseconds);

  factory DurationValue.parse(String literal) {
    final int totalMillis = _parseDuration(literal);
    return DurationValue(_intToInt64(totalMillis));
  }

  final Int64 milliseconds;

  String toCanonicalString() => _formatDuration(milliseconds);

  Int64 toMilliseconds() => milliseconds;

  Int64 toSeconds() => _intToInt64(milliseconds.toInt() ~/ _kMillisPerSecond);

  Int64 toMinutes() => _intToInt64(milliseconds.toInt() ~/ _kMillisPerMinute);

  Int64 toHours() => _intToInt64(milliseconds.toInt() ~/ _kMillisPerHour);

  Int64 toDays() => _intToInt64(milliseconds.toInt() ~/ _kMillisPerDay);

  String asExtensionLiteral() => 'duration("${toCanonicalString()}")';

  @override
  Map<String, Object?> toJson() => {
    '__extn': {'fn': 'duration', 'arg': toCanonicalString()},
  };

  @override
  pb.Value toProto() => pb.Value(
    extensionCall: pb.ExtensionCall(
      fn: 'duration',
      arg: Value.string(toCanonicalString()).toProto(),
    ),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurationValue && milliseconds == other.milliseconds;

  @override
  int get hashCode => Object.hash(DurationValue, milliseconds);

  @override
  String toString() => asExtensionLiteral();
}

int _parseDuration(String input) {
  final int length = input.length;
  if (length <= 1) {
    _durationError('string too short');
  }

  var index = 0;
  var unitIndex = 0;
  var negative = 1;
  if (input.codeUnitAt(index) == 0x2D) {
    // '-'
    negative = -1;
    index++;
    if (length <= 1) {
      _durationError('string too short');
    }
  }

  var total = 0;
  var value = 0;
  var hasValue = false;

  while (index < length && unitIndex < _durationUnits.length) {
    final int codeUnit = input.codeUnitAt(index);
    if (_isDigit(codeUnit)) {
      value = value * 10 + (codeUnit - 0x30);
      if (value > 0x7fffffff) {
        _durationError('overflow');
      }
      hasValue = true;
      index++;
      continue;
    }

    if (codeUnit == 0x64 || // d
        codeUnit == 0x68 || // h
        codeUnit == 0x6D || // m
        codeUnit == 0x73) // s
    {
      if (!hasValue) {
        _durationError('unit found without quantity');
      }

      var unit = String.fromCharCode(codeUnit);
      if (codeUnit == 0x6D &&
          index + 1 < length &&
          input.codeUnitAt(index + 1) == 0x73) {
        unit = 'ms';
        index++;
      }

      var unitOk = false;
      while (!unitOk && unitIndex < _durationUnits.length) {
        if (unit == _durationUnits[unitIndex]) {
          unitOk = true;
        }
        unitIndex++;
      }

      if (!unitOk) {
        _durationError("unexpected unit '$unit'");
      }

      final int addition = value * _durationUnitToMillis[unit]!;
      total += addition;
      if (!_isWithinInt64(total)) {
        _durationError('overflow');
      }
      hasValue = false;
      value = 0;
      index++;
      continue;
    }

    _durationError('unexpected character ${_quoteRune(codeUnit)}');
  }

  if (hasValue) {
    _durationError('expected unit');
  }

  if (index < length) {
    _durationError('invalid duration');
  }

  final int result = negative * total;
  if (!_isWithinInt64(result)) {
    _durationError('overflow');
  }
  return result;
}

Never _durationError(String message) {
  throw ArgumentError('error parsing duration value: $message');
}

const List<String> _durationUnits = ['d', 'h', 'm', 's', 'ms'];
const Map<String, int> _durationUnitToMillis = {
  'd': _kMillisPerDay,
  'h': _kMillisPerHour,
  'm': _kMillisPerMinute,
  's': _kMillisPerSecond,
  'ms': 1,
};

String _formatDuration(Int64 milliseconds) {
  final int value = milliseconds.toInt();
  if (value == 0) {
    return '0ms';
  }

  final StringBuffer buffer = StringBuffer();
  var remaining = value;
  if (remaining < 0) {
    buffer.write('-');
    remaining = -remaining;
  }

  final int days = remaining ~/ _kMillisPerDay;
  if (days > 0) {
    buffer
      ..write(days)
      ..write('d');
  }
  remaining %= _kMillisPerDay;

  final int hours = remaining ~/ _kMillisPerHour;
  if (hours > 0) {
    buffer
      ..write(hours)
      ..write('h');
  }
  remaining %= _kMillisPerHour;

  final int minutes = remaining ~/ _kMillisPerMinute;
  if (minutes > 0) {
    buffer
      ..write(minutes)
      ..write('m');
  }
  remaining %= _kMillisPerMinute;

  final int seconds = remaining ~/ _kMillisPerSecond;
  if (seconds > 0) {
    buffer
      ..write(seconds)
      ..write('s');
  }
  remaining %= _kMillisPerSecond;

  if (remaining > 0) {
    buffer
      ..write(remaining)
      ..write('ms');
  }

  return buffer.toString();
}
