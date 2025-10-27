part of '../value.dart';

/// Cedar value that represents a span of time measured in milliseconds.
final class DurationValue extends Value {
  const DurationValue(this.milliseconds, {this.literal});

  /// Parses a Cedar `duration` extension literal into a [DurationValue].
  factory DurationValue.parse(String literal) {
    final int totalMillis = _parseDuration(literal);
    return DurationValue(_intToInt64(totalMillis), literal: literal);
  }

  final Int64 milliseconds;
  final String? literal;

  /// Returns the canonical Cedar string form (e.g. `1h20m`).
  String toCanonicalString() => _formatDuration(milliseconds);

  /// Exposes the raw milliseconds contained in this duration.
  Int64 toMilliseconds() => milliseconds;

  /// Returns the whole seconds contained in this duration.
  Int64 toSeconds() => _intToInt64(milliseconds.toInt() ~/ _kMillisPerSecond);

  /// Returns the whole minutes contained in this duration.
  Int64 toMinutes() => _intToInt64(milliseconds.toInt() ~/ _kMillisPerMinute);

  /// Returns the whole hours contained in this duration.
  Int64 toHours() => _intToInt64(milliseconds.toInt() ~/ _kMillisPerHour);

  /// Returns the whole days contained in this duration.
  Int64 toDays() => _intToInt64(milliseconds.toInt() ~/ _kMillisPerDay);

  /// Yields the Cedar extension literal for this duration.
  String asExtensionLiteral() => 'duration("${toCanonicalString()}")';

  @override
  Map<String, Object?> toJson() => {
    '__extn': {
      'fn': 'duration',
      'arg': literal ?? _formatDuration(milliseconds),
    },
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

/// Parses a Cedar `duration` literal into an integer millisecond count.
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

  var total = BigInt.zero;
  var value = BigInt.zero;
  var hasValue = false;

  while (index < length && unitIndex < _durationUnits.length) {
    final int codeUnit = input.codeUnitAt(index);
    if (_isDigit(codeUnit)) {
      // Accumulate the magnitude for the upcoming unit, checking Int64 bounds.
      value = (value * BigInt.from(10)) + BigInt.from(codeUnit - 0x30);
      if (!_bigIntWithinInt64(value)) {
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
        // Treat "ms" as a single unit and advance past both characters.
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

      // Aggregate total milliseconds while respecting the Int64 envelope.
      final BigInt addition = value * _durationUnitToMillisBigInt[unit]!;
      total += addition;
      if (!_bigIntWithinInt64(total)) {
        _durationError('overflow');
      }
      hasValue = false;
      value = BigInt.zero;
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

  final BigInt result = total * BigInt.from(negative);
  if (!_bigIntWithinInt64(result)) {
    _durationError('overflow');
  }
  return result.toInt();
}

/// Throws a formatted [ArgumentError] for duration parsing failures.
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

/// Lookup table for converting recognized duration units to `BigInt` millis.
final Map<String, BigInt> _durationUnitToMillisBigInt = {
  for (final entry in _durationUnitToMillis.entries)
    entry.key: BigInt.from(entry.value),
};

final BigInt _kMinInt64BigInt = BigInt.from(_kMinInt64AsInt);
final BigInt _kMaxInt64BigInt = BigInt.from(_kMaxInt64AsInt);

/// Returns true when [value] fits within the signed 64-bit range.
bool _bigIntWithinInt64(BigInt value) =>
    value >= _kMinInt64BigInt && value <= _kMaxInt64BigInt;

/// Formats a millisecond duration into the Cedar canonical string encoding.
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

  // Decompose from largest to smallest units to follow Cedar's canonical form.
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
