import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

void main() {
  group('Datetime & duration extensions', () {
    late Evalutator evaluator;

    Value evaluate(Expr expr) => expr.accept(evaluator);

    Expr stringLiteral(String value) => Expr.value(StringValue(value));

    DatetimeValue callDatetime(String literal) {
      final value = evaluate(
        Expr.extensionCall(fn: 'datetime', args: [stringLiteral(literal)]),
      );
      return value as DatetimeValue;
    }

    DurationValue callDuration(String literal) {
      final value = evaluate(
        Expr.extensionCall(fn: 'duration', args: [stringLiteral(literal)]),
      );
      return value as DurationValue;
    }

    DatetimeValue callOffset(String datetime, String duration) {
      final value = evaluate(
        Expr.extensionCall(
          fn: 'offset',
          args: [
            Expr.extensionCall(fn: 'datetime', args: [stringLiteral(datetime)]),
            Expr.extensionCall(fn: 'duration', args: [stringLiteral(duration)]),
          ],
        ),
      );
      return value as DatetimeValue;
    }

    DurationValue callDurationSince(String lhs, String rhs) {
      final value = evaluate(
        Expr.extensionCall(
          fn: 'durationSince',
          args: [
            Expr.extensionCall(fn: 'datetime', args: [stringLiteral(lhs)]),
            Expr.extensionCall(fn: 'datetime', args: [stringLiteral(rhs)]),
          ],
        ),
      );
      return value as DurationValue;
    }

    DatetimeValue callToDate(String literal) {
      final value = evaluate(
        Expr.extensionCall(
          fn: 'toDate',
          args: [
            Expr.extensionCall(fn: 'datetime', args: [stringLiteral(literal)]),
          ],
        ),
      );
      return value as DatetimeValue;
    }

    DurationValue callToTime(String literal) {
      final value = evaluate(
        Expr.extensionCall(
          fn: 'toTime',
          args: [
            Expr.extensionCall(fn: 'datetime', args: [stringLiteral(literal)]),
          ],
        ),
      );
      return value as DurationValue;
    }

    Int64 callDurationUnit(String fn, String duration) {
      final value =
          evaluate(
                Expr.extensionCall(
                  fn: fn,
                  args: [
                    Expr.extensionCall(
                      fn: 'duration',
                      args: [stringLiteral(duration)],
                    ),
                  ],
                ),
              )
              as LongValue;
      return value.value;
    }

    BoolValue callComparison(Expr expr) => evaluate(expr) as BoolValue;

    setUp(() {
      final context = EvaluationContext(
        entities: <EntityUid, Entity>{},
        principal: const EntityUid.unknown(),
        action: const EntityUid.unknown(),
        resource: const EntityUid.unknown(),
        context: const RecordValue({}),
      );
      evaluator = Evalutator(context);
    });

    test('datetime canonicalization vectors', () {
      // Copied from cedar/cedar-policy-core/src/extensions/datetime.rs:test_parse_pos.
      const rustCases = [
        ('2024-10-15', '2024-10-15T00:00:00.000Z'),
        ('2024-10-15T11:38:02Z', '2024-10-15T11:38:02.000Z'),
        ('2024-10-15T11:38:02.101Z', '2024-10-15T11:38:02.101Z'),
        ('2024-10-15T11:38:02.101+1134', '2024-10-15T00:04:02.101Z'),
        ('2024-10-15T11:38:02.101-1134', '2024-10-15T23:12:02.101Z'),
        ('2024-10-15T11:38:02+1134', '2024-10-15T00:04:02.000Z'),
        ('2024-10-15T11:38:02-1134', '2024-10-15T23:12:02.000Z'),
        ('2024-10-15T23:59:00+2359', '2024-10-15T00:00:00.000Z'),
        ('2024-10-15T00:00:00-2359', '2024-10-15T23:59:00.000Z'),
      ];

      for (final (input, expected) in rustCases) {
        expect(callDatetime(input).toIso8601String(), expected, reason: input);
      }

      const extraCases = [
        ('1970-01-01', '1970-01-01T00:00:00.000Z'),
        ('1970-10-10', '1970-10-10T00:00:00.000Z'),
        ('1970-01-01T01:01:01Z', '1970-01-01T01:01:01.000Z'),
        ('1970-01-01T00:00:00.001Z', '1970-01-01T00:00:00.001Z'),
        ('1970-01-01T00:00:00.111Z', '1970-01-01T00:00:00.111Z'),
        ('1970-01-01T00:00:00+0100', '1969-12-31T23:00:00.000Z'),
        ('1970-01-01T00:01:00-0001', '1970-01-01T00:02:00.000Z'),
        ('1972-02-29T10:00:00-1000', '1972-02-29T20:00:00.000Z'),
      ];

      for (final (input, expected) in extraCases) {
        expect(callDatetime(input).toIso8601String(), expected, reason: input);
      }
    });

    test('datetime rejects invalid vectors', () {
      const cases = [
        ('', 'error parsing datetime value: string too short'),
        ('-', 'error parsing datetime value: string too short'),
        ('195-01-01T00:00:00Z', 'error parsing datetime value: invalid year'),
        (
          '1995-01-01T00:00:00.000Z+',
          'error parsing datetime value: unexpected trailer after time zone designator',
        ),
        (
          '1995-01-01T00:00:00.000+',
          'error parsing datetime value: invalid time zone offset',
        ),
        (
          '1995-01-01T00:00:00.000-0',
          'error parsing datetime value: invalid time zone offset',
        ),
        ('1995-04-31T00:00:00Z', 'error parsing datetime value: invalid date'),
        ('2024-02-30T00:00:00Z', 'error parsing datetime value: invalid date'),
        (
          '2024-02-29T23:59:60Z',
          'error parsing datetime value: second is out of range',
        ),
        (
          '1970-01-01T00:00:00+2400',
          'error parsing datetime value: time zone offset hours are out of range',
        ),
        (
          '1970-01-01T00:00:00+2360',
          'error parsing datetime value: time zone offset minutes are out of range',
        ),
      ];

      for (final (input, expected) in cases) {
        expect(
          () => callDatetime(input),
          throwsA(
            isA<TypeException>().having((e) => e.message, 'message', expected),
          ),
          reason: input,
        );
      }
    });

    test('duration canonicalization vectors', () {
      const cases = [
        ('1h', '1h'),
        ('60m', '1h'),
        ('3600s', '1h'),
        ('3600000ms', '1h'),
        ('24h', '1d'),
        ('36h', '1d12h'),
        ('60s60000ms', '2m'),
        ('-62m', '-1h2m'),
        ('-2m3600s', '-1h2m'),
      ];

      for (final (input, expected) in cases) {
        expect(
          callDuration(input).toCanonicalString(),
          expected,
          reason: input,
        );
      }
    });

    test('duration rejects invalid vectors', () {
      const cases = [
        ('', 'error parsing duration value: string too short'),
        ('-', 'error parsing duration value: string too short'),
        ('-m', 'error parsing duration value: unit found without quantity'),
        ('-1t', "error parsing duration value: unexpected character 't'"),
        ('-1h1h', "error parsing duration value: unexpected unit 'h'"),
        ('-3h3', 'error parsing duration value: expected unit'),
        ('3h-1m', "error parsing duration value: unexpected character '-'"),
        ('3600ms30ms', 'error parsing duration value: invalid duration'),
        ('999999999999999999999ms', 'error parsing duration value: overflow'),
      ];

      for (final (input, expected) in cases) {
        expect(
          () => callDuration(input),
          throwsA(
            isA<TypeException>().having((e) => e.message, 'message', expected),
          ),
          reason: input,
        );
      }
    });

    test('offset and durationSince', () {
      expect(
        callOffset('1970-01-01', '1ms').toIso8601String(),
        '1970-01-01T00:00:00.001Z',
      );
      expect(
        callOffset('1970-01-01T00:00:00.001Z', '-1ms').toIso8601String(),
        '1970-01-01T00:00:00.000Z',
      );
      expect(
        callDurationSince(
          '1970-01-01T00:00:00.001Z',
          '1970-01-01',
        ).toCanonicalString(),
        '1ms',
      );
    });

    test('toDate and toTime round trip', () {
      expect(
        callToDate('1970-01-01T12:34:56.789Z').toIso8601String(),
        '1970-01-01T00:00:00.000Z',
      );
      expect(
        callToDate('1969-12-31T23:59:59.999Z').toIso8601String(),
        '1969-12-31T00:00:00.000Z',
      );
      expect(
        callToTime('1970-01-01T01:02:03.004Z').toCanonicalString(),
        '1h2m3s4ms',
      );
      expect(
        callToTime('1969-12-31T23:59:59.999Z').toCanonicalString(),
        '23h59m59s999ms',
      );
    });

    test('duration unit conversions', () {
      const literal = '1d12h31m43s17ms';
      expect(callDurationUnit('toDays', literal).toInt(), 1);
      expect(callDurationUnit('toHours', literal).toInt(), 36);
      expect(callDurationUnit('toMinutes', literal).toInt(), 2191);
      expect(callDurationUnit('toSeconds', literal).toInt(), 131503);
      expect(callDurationUnit('toMilliseconds', literal).toInt(), 131503017);
    });

    test('comparisons support datetime and duration', () {
      final datetimeLt = ExprLessThan(
        left: Expr.extensionCall(
          fn: 'datetime',
          args: [stringLiteral('1970-01-01T00:00:00.000Z')],
        ),
        right: Expr.extensionCall(
          fn: 'datetime',
          args: [stringLiteral('1970-01-02T00:00:00.000Z')],
        ),
      );
      expect(callComparison(datetimeLt).value, isTrue);

      final durationGt = ExprGreaterThan(
        left: Expr.extensionCall(fn: 'duration', args: [stringLiteral('2h')]),
        right: Expr.extensionCall(fn: 'duration', args: [stringLiteral('90m')]),
      );
      expect(callComparison(durationGt).value, isTrue);
    });
  });
}
