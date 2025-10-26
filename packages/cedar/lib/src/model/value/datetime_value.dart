part of '../value.dart';

const int _kMillisPerSecond = 1000;
const int _kMillisPerMinute = 60 * _kMillisPerSecond;
const int _kMillisPerHour = 60 * _kMillisPerMinute;
const int _kMillisPerDay = 24 * _kMillisPerHour;
final Int64 _kMinInt64 = Int64.MIN_VALUE;
final Int64 _kMaxInt64 = Int64.MAX_VALUE;
final int _kMinInt64AsInt = _kMinInt64.toInt();
final int _kMaxInt64AsInt = _kMaxInt64.toInt();

final class DatetimeValue extends Value {
  const DatetimeValue(this.milliseconds, {this.literal});

  factory DatetimeValue.parse(String literal) {
    final int epochMillis = _parseDatetime(literal);
    return DatetimeValue(_intToInt64(epochMillis), literal: literal);
  }

  final Int64 milliseconds;
  final String? literal;

  String toIso8601String() => literal ?? _formatIso8601(milliseconds);

  DatetimeValue offset(DurationValue duration) {
    final BigInt result =
        BigInt.from(milliseconds.toInt()) +
        BigInt.from(duration.milliseconds.toInt());
    if (!_bigIntWithinInt64(result)) {
      throw ArgumentError(
        'overflows when adding an offset: ${asExtensionLiteral()}+(${duration.asExtensionLiteral()})',
      );
    }
    return DatetimeValue(_intToInt64(result.toInt()));
  }

  DurationValue durationSince(DatetimeValue other) {
    final BigInt result =
        BigInt.from(milliseconds.toInt()) -
        BigInt.from(other.milliseconds.toInt());
    if (!_bigIntWithinInt64(result)) {
      throw ArgumentError(
        'overflows when computing the duration between ${asExtensionLiteral()} and ${other.asExtensionLiteral()}',
      );
    }
    return DurationValue(_intToInt64(result.toInt()));
  }

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

  DurationValue toTime() {
    final int epoch = milliseconds.toInt();
    final int remainder = epoch % _kMillisPerDay;
    return DurationValue(_intToInt64(remainder));
  }

  String asExtensionLiteral() => 'datetime("${toIso8601String()}")';

  @override
  Map<String, Object?> toJson() => {
    '__extn': {'fn': 'datetime', 'arg': toIso8601String()},
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

Never _datetimeError(String message) {
  throw ArgumentError('error parsing datetime value: $message');
}

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

int _parseTwoDigits(String input, int start, String errorMessage) {
  final int a = input.codeUnitAt(start);
  final int b = input.codeUnitAt(start + 1);
  if (!_isDigit(a) || !_isDigit(b)) {
    _datetimeError(errorMessage);
  }
  return (a - 0x30) * 10 + (b - 0x30);
}

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

String _formatIso8601(Int64 milliseconds) {
  final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
    milliseconds.toInt(),
    isUtc: true,
  );
  final String year = dateTime.year.toString().padLeft(4, '0');
  final String month = dateTime.month.toString().padLeft(2, '0');
  final String day = dateTime.day.toString().padLeft(2, '0');
  final String hour = dateTime.hour.toString().padLeft(2, '0');
  final String minute = dateTime.minute.toString().padLeft(2, '0');
  final String second = dateTime.second.toString().padLeft(2, '0');
  final String millisecond = dateTime.millisecond.toString().padLeft(3, '0');
  return '$year-$month-${day}T$hour:$minute:$second.${millisecond}Z';
}
