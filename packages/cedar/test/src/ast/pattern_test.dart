import 'package:cedar/ast.dart';
import 'package:test/test.dart';

void main() {
  group('CedarPattern', () {
    test('saturate two wildcards', () {
      final pattern1 = CedarPattern.from(const [Wildcard(), Wildcard()]);
      final pattern2 = CedarPattern.from(const [Wildcard()]);
      expect(pattern1, equals(pattern2));
    });

    test('saturate two literals', () {
      final pattern1 =
          CedarPattern.from(const [Literal('foo'), Literal('bar')]);
      final pattern2 = CedarPattern.from(const [Literal('foobar')]);
      expect(pattern1, equals(pattern2));
    });

    test('toCedar', () {
      final pattern = CedarPattern.from(const [Literal('*foo'), Wildcard()]);
      expect(pattern.toCedar(), equals(r'"\*foo*"'));
    });

    test('parse', () {
      final pattern = CedarPattern.parse('*foo*');
      expect(
        pattern,
        equals(CedarPattern.from(const [
          Wildcard(),
          Literal('foo'),
          Wildcard(),
        ])),
      );
      expect(pattern.toString(), '*foo*');
    });

    test('parse escaped', () {
      const raw = r'*\*foo*\n\t\u{fffff}*';
      final pattern = CedarPattern.parse(raw);
      expect(
        pattern,
        equals(CedarPattern.from(const [
          Wildcard(),
          Literal('*foo'),
          Wildcard(),
          Literal('\n\t\u{FFFFF}'),
          Wildcard(),
        ])),
      );
      expect(pattern.toString(), raw);
    });
  });
}
