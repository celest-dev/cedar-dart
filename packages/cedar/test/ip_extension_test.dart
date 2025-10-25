import 'package:cedar/ast.dart';
import 'package:cedar/src/eval/evalutator.dart';
import 'package:test/test.dart';

void main() {
  group('IP extensions', () {
    late Evalutator evaluator;

    Value evaluateExpr(Expr expr) => expr.accept(evaluator);

    String callIp(String literal) {
      final value =
          evaluateExpr(
                Expr.extensionCall(
                  fn: 'ip',
                  args: [Expr.value(StringValue(literal))],
                ),
              )
              as StringValue;
      return value.value;
    }

    bool callUnaryPredicate(String fn, String literal) {
      final value =
          evaluateExpr(
                Expr.extensionCall(
                  fn: fn,
                  args: [
                    Expr.extensionCall(
                      fn: 'ip',
                      args: [Expr.value(StringValue(literal))],
                    ),
                  ],
                ),
              )
              as BoolValue;
      return value.value;
    }

    bool callIsInRange(String base, String range) {
      final value =
          evaluateExpr(
                Expr.extensionCall(
                  fn: 'isInRange',
                  args: [
                    Expr.extensionCall(
                      fn: 'ip',
                      args: [Expr.value(StringValue(base))],
                    ),
                    Expr.extensionCall(
                      fn: 'ip',
                      args: [Expr.value(StringValue(range))],
                    ),
                  ],
                ),
              )
              as BoolValue;
      return value.value;
    }

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

    test('ip preserves host bits for CIDR prefixes', () {
      final expr = Expr.extensionCall(
        fn: 'ip',
        args: [Expr.value(const StringValue('127.0.0.1/16'))],
      );

      final value = evaluateExpr(expr) as StringValue;
      expect(value.value, '127.0.0.1/16');
    });

    test('ip parse vectors from reference implementations', () {
      const cases = [
        ('0.0.0.0', '0.0.0.0'),
        ('0.0.0.1', '0.0.0.1'),
        ('127.0.0.1', '127.0.0.1'),
        ('127.0.0.1/32', '127.0.0.1'),
        ('127.0.0.1/24', '127.0.0.1/24'),
        ('127.1.2.3/8', '127.1.2.3/8'),
        ('::', '::'),
        ('::/128', '::'),
        ('::1', '::1'),
        ('::1/128', '::1'),
        ('2001:db8::1', '2001:db8::1'),
        ('2001:db8::1:0:0:1', '2001:db8::1:0:0:1'),
        ('::ffff:c000:0280', '::ffff:192.0.2.128'),
        ('::ffff:c000:0280/24', '::ffff:192.0.2.128/24'),
        ('::ffff:c000:0280/120', '::ffff:192.0.2.128/120'),
        ('2001:db8::1/32', '2001:db8::1/32'),
        ('2001:db8::1:0:0:1/96', '2001:db8::1:0:0:1/96'),
        (
          'c5c5:c5c5:c5c5:c5c5:c5c5:c5c5:c5c5:c5c5/68',
          'c5c5:c5c5:c5c5:c5c5:c5c5:c5c5:c5c5:c5c5/68',
        ),
      ];

      for (final (input, expected) in cases) {
        expect(callIp(input), expected, reason: 'literal: $input');
      }
    });

    test('ip rejects invalid vectors from reference implementations', () {
      const cases = [
        '380.0.0.1',
        '?',
        'ab.ab.ab.ab',
        'foo::1',
        '::ffff:127.0.0.1',
        '::127.0.0.1',
        '::ffff:192.0.2.128',
        '6b6b:f00::32ff:ffff:6368/00',
        '::ffff:192.0.2.128/24',
        '::ffff:192.0.2.128/120',
        '127.0.0.1/8/24',
        'fee::/64::1',
        '172.0.0.1/64',
        'ffee::/132',
        'ffee::/+1',
        'ffee::/01',
        'ffee::/1234',
      ];

      for (final literal in cases) {
        expect(() => callIp(literal), throwsArgumentError, reason: literal);
      }
    });

    test('ip rejects invalid literals', () {
      final expr = Expr.extensionCall(
        fn: 'ip',
        args: [Expr.value(const StringValue('not-an-ip'))],
      );

      expect(() => evaluateExpr(expr), throwsArgumentError);
    });

    test('isIpv4 handles IPv4 addresses and prefixes', () {
      final expr = Expr.extensionCall(
        fn: 'isIpv4',
        args: [
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('192.168.1.10/24'))],
          ),
        ],
      );

      final value = evaluateExpr(expr) as BoolValue;
      expect(value.value, isTrue);
    });

    test('isIpv4 and isIpv6 vectors from reference implementations', () {
      const cases = [
        ('0.0.0.0', true, false),
        ('0.0.0.0/32', true, false),
        ('127.0.0.1', true, false),
        ('127.0.0.1/32', true, false),
        ('::', false, true),
        ('::1', false, true),
        ('::/128', false, true),
        ('::1/128', false, true),
        ('::ffff:c000:0280', false, true),
        ('::ffff:c000:0280/128', false, true),
        ('::ffff:c000:0280/24', false, true),
        ('2001:db8::1', false, true),
        ('2001:db8::1:0:0:1', false, true),
        ('2001:db8::1/32', false, true),
      ];

      for (final (literal, expectedIpv4, expectedIpv6) in cases) {
        expect(
          callUnaryPredicate('isIpv4', literal),
          expectedIpv4,
          reason: 'isIpv4($literal)',
        );
        expect(
          callUnaryPredicate('isIpv6', literal),
          expectedIpv6,
          reason: 'isIpv6($literal)',
        );
      }
    });

    test('isIpv6 detects IPv6 addresses', () {
      final expr = Expr.extensionCall(
        fn: 'isIpv6',
        args: [
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('2001:db8::1'))],
          ),
        ],
      );

      final value = evaluateExpr(expr) as BoolValue;
      expect(value.value, isTrue);
    });

    test('isLoopback matches loopback ranges', () {
      final expr = Expr.extensionCall(
        fn: 'isLoopback',
        args: [
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('127.0.0.0/8'))],
          ),
        ],
      );

      final value = evaluateExpr(expr) as BoolValue;
      expect(value.value, isTrue);
    });

    test('isLoopback vectors from reference implementations', () {
      const cases = [
        ('0.0.0.0', false),
        ('127.0.0.1', true),
        ('127.0.0.2', true),
        ('127.0.0.1/32', true),
        ('127.0.0.1/24', true),
        ('127.0.0.1/8', true),
        ('127.0.0.1/7', false),
        ('::', false),
        ('::1', true),
        ('::/128', false),
        ('::1/128', true),
        ('::1/127', false),
        ('::ffff:8000:0001', false),
        ('::ffff:8000:0002', false),
        ('::ffff:8000:0001/128', false),
        ('::ffff:8000:0002/128', false),
        ('::ffff:8000:0001/104', false),
        ('::ffff:8000:0002/104', false),
        ('::ffff:8000:0001/100', false),
        ('::ffff:8000:0002/100', false),
        ('2001:db8::1', false),
      ];

      for (final (literal, expected) in cases) {
        expect(
          callUnaryPredicate('isLoopback', literal),
          expected,
          reason: 'isLoopback($literal)',
        );
      }
    });

    test('isMulticast requires minimal prefix', () {
      final multicastExpr = Expr.extensionCall(
        fn: 'isMulticast',
        args: [
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('224.0.0.0/4'))],
          ),
        ],
      );
      final notMulticastExpr = Expr.extensionCall(
        fn: 'isMulticast',
        args: [
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('224.0.0.0/1'))],
          ),
        ],
      );

      expect((evaluateExpr(multicastExpr) as BoolValue).value, isTrue);
      expect((evaluateExpr(notMulticastExpr) as BoolValue).value, isFalse);
    });

    test('isMulticast vectors from reference implementations', () {
      const cases = [
        ('0.0.0.0', false),
        ('127.0.0.1', false),
        ('223.255.255.255', false),
        ('224.0.0.0', true),
        ('239.255.255.255', true),
        ('240.0.0.0', false),
        ('feff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', false),
        ('ff00::', true),
        ('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', true),
        ('ff00::/8', true),
        ('ff00::/7', false),
        ('224.0.0.0/4', true),
        ('224.0.0.0/3', false),
      ];

      for (final (literal, expected) in cases) {
        expect(
          callUnaryPredicate('isMulticast', literal),
          expected,
          reason: 'isMulticast($literal)',
        );
      }
    });

    test('isInRange evaluates CIDR membership', () {
      final expr = Expr.extensionCall(
        fn: 'isInRange',
        args: [
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('10.0.0.1'))],
          ),
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('10.0.0.0/24'))],
          ),
        ],
      );

      final value = evaluateExpr(expr) as BoolValue;
      expect(value.value, isTrue);
    });

    test('isInRange returns false outside CIDR', () {
      final expr = Expr.extensionCall(
        fn: 'isInRange',
        args: [
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('10.0.1.1'))],
          ),
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('10.0.0.0/24'))],
          ),
        ],
      );

      final value = evaluateExpr(expr) as BoolValue;
      expect(value.value, isFalse);
    });

    test('isInRange vectors from reference implementations', () {
      const cases = [
        ('0.0.0.0', '0.0.0.0/31', true),
        ('0.0.0.0/31', '0.0.0.0', false),
        ('255.255.255.255', '255.255.0.0/16', true),
        ('255.255.255.248/28', '255.255.0.0/16', true),
        ('255.255.255.0/24', '255.255.0.0/16', true),
        ('255.255.248.0/20', '255.255.0.0/16', true),
        ('255.255.0.0/16', '255.255.0.0/16', true),
        ('255.254.0.0/15', '255.255.0.0/16', false),
        ('255.254.255.0/24', '255.255.0.0/16', false),
        ('192.0.2.128', '::ffff:c000:0280', false),
        ('2001:db8::2', '2001:db8::/120', true),
        ('2001:db8:0:0:dead:f00d::/96', '2001:db8::/64', true),
      ];

      for (final (base, range, expected) in cases) {
        expect(callIsInRange(base, range), expected, reason: '$base in $range');
      }
    });

    test('isInRange rejects invalid CIDR', () {
      final expr = Expr.extensionCall(
        fn: 'isInRange',
        args: [
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('10.0.0.1'))],
          ),
          Expr.extensionCall(
            fn: 'ip',
            args: [Expr.value(const StringValue('10.0.0.0/33'))],
          ),
        ],
      );

      expect(() => evaluateExpr(expr), throwsArgumentError);
    });
  });
}
