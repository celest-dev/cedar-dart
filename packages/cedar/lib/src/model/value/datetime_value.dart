part of '../value.dart';

// Utilities for representing Cedar `datetime` values and converting between
// extension JSON, internal `Int64` timestamps, and ISO-8601 text.

const int _kMillisPerSecond = 1000;
const int _kMillisPerMinute = 60 * _kMillisPerSecond;
const int _kMillisPerHour = 60 * _kMillisPerMinute;
const int _kMillisPerDay = 24 * _kMillisPerHour;
final Int64 _kMinInt64 = Int64.MIN_VALUE;
final Int64 _kMaxInt64 = Int64.MAX_VALUE;
final int _kMinInt64AsInt = _kMinInt64.toInt();
final int _kMaxInt64AsInt = _kMaxInt64.toInt();
final BigInt _kMillisPerSecondBigInt = BigInt.from(_kMillisPerSecond);
final BigInt _kMillisPerMinuteBigInt = BigInt.from(_kMillisPerMinute);
final BigInt _kMillisPerHourBigInt = BigInt.from(_kMillisPerHour);
final BigInt _kMillisPerDayBigInt = BigInt.from(_kMillisPerDay);
final BigInt _k400BigInt = BigInt.from(400);
final BigInt _k365BigInt = BigInt.from(365);
final BigInt _k1460BigInt = BigInt.from(1460);
final BigInt _k36524BigInt = BigInt.from(36524);
final BigInt _k146096BigInt = BigInt.from(146096);
final BigInt _k5BigInt = BigInt.from(5);
final BigInt _k153BigInt = BigInt.from(153);

/// Cedar value that models an instant in time as milliseconds from Unix epoch.
final class DatetimeValue extends Value {
  const DatetimeValue(
    this.milliseconds, {
    this.literal,
    DatetimeExtensionRepr? repr,
  }) : _repr = repr;

  /// Parses an ISO-8601 `datetime` extension literal into a [DatetimeValue].
  factory DatetimeValue.parse(String literal) {
    final int epochMillis = _parseDatetime(literal);
    return DatetimeValue(_intToInt64(epochMillis), literal: literal);
  }

  final Int64 milliseconds;
  final String? literal;
  final DatetimeExtensionRepr? _repr;

  /// Returns this instant formatted as an ISO-8601 UTC timestamp.
  String toIso8601String() => _formatIso8601(milliseconds);

  /// Returns a new [DatetimeValue] offset by the supplied duration.
  DatetimeValue offset(DurationValue duration) {
    final BigInt result =
        milliseconds.toBigInt() + duration.milliseconds.toBigInt();
    if (!_bigIntWithinInt64(result)) {
      throw ArgumentError(
        'overflows when adding an offset: ${asExtensionLiteral()}+(${duration.asExtensionLiteral()})',
      );
    }
    return DatetimeValue(_intToInt64(result.toInt()));
  }

  /// Calculates the duration between this value and [other].
  DurationValue durationSince(DatetimeValue other) {
    final BigInt result =
        milliseconds.toBigInt() - other.milliseconds.toBigInt();
    if (!_bigIntWithinInt64(result)) {
      throw ArgumentError(
        'overflows when computing the duration between ${asExtensionLiteral()} and ${other.asExtensionLiteral()}',
      );
    }
    return DurationValue(_intToInt64(result.toInt()));
  }

  /// Truncates this instant to midnight UTC, returning only the date portion.
  DatetimeValue toDate() {
    final int epoch = milliseconds.toInt();
    final int result;
    if (epoch < 0) {
      final int remainder = epoch % _kMillisPerDay;
      if (remainder == 0) {
        result = epoch;
      } else {
        final int quotient = (epoch ~/ _kMillisPerDay) - 1;
        result = quotient * _kMillisPerDay;
      }
    } else {
      final int quotient = epoch ~/ _kMillisPerDay;
      result = quotient * _kMillisPerDay;
    }
    if (!_isWithinInt64(result)) {
      throw ArgumentError(
        'overflows when computing the date of ${asExtensionLiteral()}',
      );
    }
    return DatetimeValue(_intToInt64(result));
  }

  /// Returns the time-of-day component as a [DurationValue].
  DurationValue toTime() {
    final int epoch = milliseconds.toInt();
    final int remainder = epoch % _kMillisPerDay;
    return DurationValue(_intToInt64(remainder));
  }

  /// Returns the Cedar extension literal representation of this value.
  String asExtensionLiteral() => 'datetime("${toIso8601String()}")';

  @override
  Map<String, Object?> toJson() => switch (_repr) {
    final DatetimeExtensionRepr repr? => repr.toJson(),
    null => {
      '__extn': {
        'fn': 'datetime',
        'arg': literal ?? _formatIso8601(milliseconds),
      },
    },
  };

  @override
  pb.Value toProto() => pb.Value(
    extensionCall: pb.ExtensionCall(
      fn: 'datetime',
      arg: Value.string(toIso8601String()).toProto(),
    ),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatetimeValue && milliseconds == other.milliseconds;

  @override
  int get hashCode => Object.hash(DatetimeValue, milliseconds);

  @override
  String toString() => asExtensionLiteral();
}

Int64 _intToInt64(int value) {
  if (!_isWithinInt64(value)) {
    throw ArgumentError('int value out of Int64 range: $value');
  }
  return Int64(value);
}

bool _isWithinInt64(int value) =>
    value >= _kMinInt64AsInt && value <= _kMaxInt64AsInt;

/// Parses a Cedar `datetime` literal as milliseconds since the Unix epoch.
int _parseDatetime(String input) {
  final int length = input.length;
  if (length < 10) {
    _datetimeError('string too short');
  }

  final int year = _parseFourDigits(input, 0, 'invalid year');

  if (input.codeUnitAt(4) != 0x2D) {
    _datetimeUnexpectedChar(input, 4);
  }

  final int month = _parseTwoDigits(input, 5, 'invalid month');
  if (month > 12) {
    _datetimeError('month is out of range');
  }

  if (input.codeUnitAt(7) != 0x2D) {
    _datetimeUnexpectedChar(input, 7);
  }

  final int day = _parseTwoDigits(input, 8, 'invalid day');
  if (day > 31) {
    _datetimeError('day is out of range');
  }

  if (length == 10) {
    final DateTime date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      _datetimeError('invalid date');
    }
    return date.millisecondsSinceEpoch;
  }

  if (length < 20) {
    _datetimeError('invalid time');
  }

  if (input.codeUnitAt(10) != 0x54) {
    _datetimeUnexpectedChar(input, 10);
  }

  final int hour = _parseTwoDigits(input, 11, 'invalid hour');
  if (hour > 23) {
    _datetimeError('hour is out of range');
  }

  if (input.codeUnitAt(13) != 0x3A) {
    _datetimeUnexpectedChar(input, 13);
  }

  final int minute = _parseTwoDigits(input, 14, 'invalid minute');
  if (minute > 59) {
    _datetimeError('minute is out of range');
  }

  if (input.codeUnitAt(16) != 0x3A) {
    _datetimeUnexpectedChar(input, 16);
  }

  final int second = _parseTwoDigits(input, 17, 'invalid second');
  if (second > 59) {
    _datetimeError('second is out of range');
  }

  var trailerOffset = 19;
  var millisecond = 0;
  if (input.codeUnitAt(19) == 0x2E) {
    if (length < 23) {
      _datetimeError('invalid millisecond');
    }
    millisecond = _parseThreeDigits(input, 20, 'invalid millisecond');
    trailerOffset = 23;
  }

  if (length == trailerOffset) {
    _datetimeError('expected time zone designator');
  }

  final int tzChar = input.codeUnitAt(trailerOffset);
  int offsetMillis;
  if (tzChar == 0x5A) {
    if (length > trailerOffset + 1) {
      _datetimeError('unexpected trailer after time zone designator');
    }
    offsetMillis = 0;
  } else if (tzChar == 0x2B || tzChar == 0x2D) {
    final int sign = tzChar == 0x2D ? -1 : 1;
    if (length > trailerOffset + 5) {
      _datetimeError('unexpected trailer after time zone designator');
    } else if (length != trailerOffset + 5) {
      _datetimeError('invalid time zone offset');
    }
    final int hourOffset = _parseTwoDigits(
      input,
      trailerOffset + 1,
      'invalid time zone offset',
    );
    final int minuteOffset = _parseTwoDigits(
      input,
      trailerOffset + 3,
      'invalid time zone offset',
    );
    if (hourOffset > 23) {
      _datetimeError('time zone offset hours are out of range');
    }
    if (minuteOffset > 59) {
      _datetimeError('time zone offset minutes are out of range');
    }
    offsetMillis =
        sign *
        ((hourOffset * _kMillisPerHour) + (minuteOffset * _kMillisPerMinute));
  } else {
    _datetimeError('invalid time zone designator');
  }

  final DateTime dateTime = DateTime.utc(
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
  );

  if (dateTime.year != year || dateTime.month != month || dateTime.day != day) {
    _datetimeError('invalid date');
  }

  return dateTime
      .subtract(Duration(milliseconds: offsetMillis))
      .millisecondsSinceEpoch;
}

void _datetimeUnexpectedChar(String input, int index) {
  final rune = input.codeUnitAt(index);
  _datetimeError('unexpected character ${_quoteRune(rune)}');
}

/// Throws a formatted [ArgumentError] for datetime parsing failures.
Never _datetimeError(String message) {
  throw ArgumentError('error parsing datetime value: $message');
}

/// Reads four ASCII digits and interprets them as an integer.
int _parseFourDigits(String input, int start, String errorMessage) {
  final int a = input.codeUnitAt(start);
  final int b = input.codeUnitAt(start + 1);
  final int c = input.codeUnitAt(start + 2);
  final int d = input.codeUnitAt(start + 3);
  if (!_isDigit(a) || !_isDigit(b) || !_isDigit(c) || !_isDigit(d)) {
    _datetimeError(errorMessage);
  }
  return (a - 0x30) * 1000 + (b - 0x30) * 100 + (c - 0x30) * 10 + (d - 0x30);
}

/// Reads two ASCII digits and interprets them as an integer.
int _parseTwoDigits(String input, int start, String errorMessage) {
  final int a = input.codeUnitAt(start);
  final int b = input.codeUnitAt(start + 1);
  if (!_isDigit(a) || !_isDigit(b)) {
    _datetimeError(errorMessage);
  }
  return (a - 0x30) * 10 + (b - 0x30);
}

/// Reads three ASCII digits and interprets them as an integer.
int _parseThreeDigits(String input, int start, String errorMessage) {
  final int a = input.codeUnitAt(start);
  final int b = input.codeUnitAt(start + 1);
  final int c = input.codeUnitAt(start + 2);
  if (!_isDigit(a) || !_isDigit(b) || !_isDigit(c)) {
    _datetimeError(errorMessage);
  }
  return (a - 0x30) * 100 + (b - 0x30) * 10 + (c - 0x30);
}

bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;

/// Renders an ASCII rune for inclusion inside an error message.
String _quoteRune(int codeUnit) {
  switch (codeUnit) {
    case 0x08:
      return r"'\b'";
    case 0x09:
      return r"'\t'";
    case 0x0A:
      return r"'\n'";
    case 0x0D:
      return r"'\r'";
    case 0x5C:
      return r"'\\'";
    case 0x27:
      return r"'\''";
  }
  if (codeUnit < 0x20 || codeUnit > 0x7E) {
    if (codeUnit <= 0xFFFF) {
      final hex = codeUnit.toRadixString(16).padLeft(4, '0');
      return "'\\u$hex'";
    }
    final hex = codeUnit.toRadixString(16).padLeft(8, '0');
    return "'\\U$hex'";
  }
  return "'${String.fromCharCode(codeUnit)}'";
}

/// Formats the provided `milliseconds` as an ISO-8601 UTC timestamp.
String _formatIso8601(Int64 milliseconds) {
  final BigInt ms = milliseconds.toBigInt();

  var days = ms ~/ _kMillisPerDayBigInt;
  var millisOfDay = ms - days * _kMillisPerDayBigInt;
  if (millisOfDay.isNegative) {
    // Adjust for negative timestamps to keep the remainder within [0, day).
    millisOfDay += _kMillisPerDayBigInt;
    days -= BigInt.one;
  }

  final _CivilDate date = _civilFromDays(days);

  final int hour = (millisOfDay ~/ _kMillisPerHourBigInt).toInt();
  millisOfDay %= _kMillisPerHourBigInt;
  final int minute = (millisOfDay ~/ _kMillisPerMinuteBigInt).toInt();
  millisOfDay %= _kMillisPerMinuteBigInt;
  final int second = (millisOfDay ~/ _kMillisPerSecondBigInt).toInt();
  millisOfDay %= _kMillisPerSecondBigInt;
  final int millisecond = millisOfDay.toInt();

  final String year = _formatIsoYear(date.year);
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  final String hourStr = hour.toString().padLeft(2, '0');
  final String minuteStr = minute.toString().padLeft(2, '0');
  final String secondStr = second.toString().padLeft(2, '0');
  final String millisecondStr = millisecond.toString().padLeft(3, '0');
  return '$year-$month-${day}T$hourStr:$minuteStr:$secondStr.${millisecondStr}Z';
}

/// Formats a potentially extended-range year with the required sign prefix.
String _formatIsoYear(BigInt year) {
  final bool isNegative = year.isNegative;
  final BigInt absYear = year.abs();
  final String digits = absYear.toString();
  if (absYear <= BigInt.from(9999)) {
    final String padded = digits.padLeft(4, '0');
    return isNegative ? '-$padded' : padded;
  }
  if (isNegative) {
    return '-$digits';
  }
  return '+$digits';
}

/// Converts a day count since the Unix epoch to a proleptic Gregorian date.
_CivilDate _civilFromDays(BigInt days) {
  const int offset = 719468;
  const int eraLength = 146097;
  final BigInt bigOffset = BigInt.from(offset);
  final BigInt eraLen = BigInt.from(eraLength);

  // Based on Howard Hinnant's civil-from-days algorithm, extended to BigInt.
  final BigInt z = days + bigOffset;
  final BigInt era = z.isNegative
      ? (z - (eraLen - BigInt.one)) ~/ eraLen
      : z ~/ eraLen;
  final BigInt doe = z - era * eraLen; // day-of-era [0, 146096]
  final BigInt yoe =
      (doe -
          doe ~/ _k1460BigInt +
          doe ~/ _k36524BigInt -
          doe ~/ _k146096BigInt) ~/
      _k365BigInt;
  BigInt year = yoe + era * _k400BigInt;
  final BigInt doy =
      doe -
      (_k365BigInt * yoe + yoe ~/ BigInt.from(4) - yoe ~/ BigInt.from(100));
  final BigInt mp = (_k5BigInt * doy + BigInt.from(2)) ~/ _k153BigInt;
  final BigInt dayCalc =
      doy - (_k153BigInt * mp + BigInt.from(2)) ~/ _k5BigInt + BigInt.one;
  final int day = dayCalc.toInt();
  final int month;
  if (mp < BigInt.from(10)) {
    month = (mp + BigInt.from(3)).toInt();
  } else {
    month = (mp - BigInt.from(9)).toInt();
  }
  if (month <= 2) {
    year += BigInt.one;
  }
  return _CivilDate(year, month, day);
}

/// Immutable representation of a proleptic Gregorian civil date.
class _CivilDate {
  const _CivilDate(this.year, this.month, this.day);

  final BigInt year;
  final int month;
  final int day;
}

/// Retains the original Cedar extension invocation for JSON round-tripping.
class DatetimeExtensionRepr {
  const DatetimeExtensionRepr({required this.fn, this.args = const []});

  final String fn;
  final List<Value> args;

  Map<String, Object?> toJson() => {
    '__extn': {
      'fn': fn,
      if (args.isNotEmpty) 'args': args.map((value) => value.toJson()).toList(),
    },
  };
}

extension on Int64 {
  /// Converts this Int64 to a BigInt for arithmetic.
  BigInt toBigInt() => BigInt.from(toInt());
}
