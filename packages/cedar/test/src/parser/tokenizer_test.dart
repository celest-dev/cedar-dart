import 'package:cedar/src/parser/tokenizer.dart';
import 'package:fixnum/fixnum.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:test/test.dart';

Matcher matchesToken(TokenType type, String text, int start, [int? end]) {
  end ??= start;
  return predicate(
    (Token token) {
      return token.type == type &&
          token.text == text &&
          token.span.start.offset == start &&
          token.span.end.offset == end;
    },
    'matches token $type $text at offset $start-$end',
  );
}

Matcher matchesError(String message, int line, int column) {
  return throwsA(
    predicate(
      (StringScannerException e) {
        return e.message.contains(message) &&
            e.span!.start.line + 1 == line &&
            e.span!.start.column + 1 == column;
      },
      'matches error "$message" at line $line col $column',
    ),
  );
}

void main() {
  group('Tokenizer', () {
    test('tokenize', () {
      const input = r'''
These are some identifiers
0 1 1234
-1 9223372036854775807 -9223372036854775808
"" "string" "\"\'\n\r\t\\\0" "\x123" "\u{0}\u{10fFfF}"
"*" "\*" "*\**"
@.,;(){}[]+-*
:::
!!=<<=>>=
||&&
// single line comment
/*
multiline comment
// embedded comment does nothing
*/
'/%|&=ë٩
?principal
?resource''';

      final tokenizer = Tokenizer(input);
      final expected = <Matcher>[
        /// Identifiers
        matchesToken(TokenType.ident, 'These', 0, 5),
        matchesToken(TokenType.ident, 'are', 6, 9),
        matchesToken(TokenType.ident, 'some', 10, 14),
        matchesToken(TokenType.ident, 'identifiers', 15, 26),

        /// Integers
        matchesToken(TokenType.int, '0', 27, 28),
        matchesToken(TokenType.int, '1', 29, 30),
        matchesToken(TokenType.int, '1234', 31, 35),

        /// Negative integers
        matchesToken(TokenType.operator, '-', 36, 37),
        matchesToken(TokenType.int, '1', 37, 38),
        matchesToken(TokenType.int, '9223372036854775807', 39, 58),
        matchesToken(TokenType.operator, '-', 59, 60),
        matchesToken(TokenType.int, '9223372036854775808', 60, 79),

        /// Strings
        matchesToken(TokenType.string, '""', 80, 82),
        matchesToken(TokenType.string, '"string"', 83, 91),
        matchesToken(TokenType.string, '"\\"\\\'\\n\\r\\t\\\\\\0"', 92, 108),
        matchesToken(TokenType.string, '"\\x123"', 109, 116),
        matchesToken(TokenType.string, '"\\u{0}\\u{10fFfF}"', 117, 134),

        /// Wildcards
        matchesToken(TokenType.string, '"*"', 135, 138),
        matchesToken(TokenType.string, '"\\*"', 139, 143),
        matchesToken(TokenType.string, '"*\\**"', 144, 150),

        /// Operators
        matchesToken(TokenType.operator, '@', 151, 152),
        matchesToken(TokenType.operator, '.', 152, 153),
        matchesToken(TokenType.operator, ',', 153, 154),
        matchesToken(TokenType.operator, ';', 154, 155),
        matchesToken(TokenType.operator, '(', 155, 156),
        matchesToken(TokenType.operator, ')', 156, 157),
        matchesToken(TokenType.operator, '{', 157, 158),
        matchesToken(TokenType.operator, '}', 158, 159),
        matchesToken(TokenType.operator, '[', 159, 160),
        matchesToken(TokenType.operator, ']', 160, 161),
        matchesToken(TokenType.operator, '+', 161, 162),
        matchesToken(TokenType.operator, '-', 162, 163),
        matchesToken(TokenType.operator, '*', 163, 164),

        /// Separators
        matchesToken(TokenType.operator, '::', 165, 167),
        matchesToken(TokenType.operator, ':', 167, 168),

        /// Comparison operators
        matchesToken(TokenType.operator, '!', 169, 170),
        matchesToken(TokenType.operator, '!=', 170, 172),
        matchesToken(TokenType.operator, '<', 172, 173),
        matchesToken(TokenType.operator, '<=', 173, 175),
        matchesToken(TokenType.operator, '>', 175, 176),
        matchesToken(TokenType.operator, '>=', 176, 178),

        /// AND | OR
        matchesToken(TokenType.operator, '||', 179, 181),
        matchesToken(TokenType.operator, '&&', 181, 183),

        /// Unknowns
        matchesToken(TokenType.unknown, "'", 264, 265),
        matchesToken(TokenType.unknown, '/', 265, 266),
        matchesToken(TokenType.unknown, '%', 266, 267),
        matchesToken(TokenType.unknown, '|', 267, 268),
        matchesToken(TokenType.unknown, '&', 268, 269),
        matchesToken(TokenType.unknown, '=', 269, 270),
        matchesToken(TokenType.unknown, 'ë', 270, 271),
        matchesToken(TokenType.unknown, '٩', 271, 272),

        /// Slots
        matchesToken(TokenType.slot, '?principal', 273, 283),
        matchesToken(TokenType.slot, '?resource', 284, 293),

        /// EOF
        matchesToken(TokenType.eof, '', input.length),
      ];

      expect(tokenizer.tokenize(), orderedEquals(expected));
    });

    test('errors', () {
      const errorTests = <_ErrorTest>[
        (
          input: 'okay\x00not okay',
          message: 'Invalid character NUL',
          position: (1, 6),
        ),
        (
          input: 'okay /*\nstuff',
          message: 'Comment not terminated',
          position: (1, 6),
        ),
        (
          input: 'okay "\n" not okay',
          message: 'Literal not terminated',
          position: (1, 7),
        ),
        (
          input: '"okay" "\\a"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\b"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\f"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\v"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\1"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\x"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\x1"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\ubadf"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\U0000badf"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\u{}"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\u{0000000}"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
        (
          input: '"okay" "\\u{z"',
          message: 'Invalid character escape',
          position: (1, 9),
        ),
      ];
      for (final errorTest in errorTests) {
        final tokenizer = Tokenizer(errorTest.input);
        final (line, column) = errorTest.position;
        expect(
          () => tokenizer.tokenize(),
          matchesError(errorTest.message, line, column),
        );
      }
    });

    test('int token values', () {
      final intValueTests = <_IntValueTest>[
        (input: '0', want: Int64.ZERO, wantErr: null),
        (
          input: '9223372036854775807',
          want: Int64.parseInt('9223372036854775807'),
          wantErr: null
        ),
        (
          input: '9223372036854775808',
          want: null,
          wantErr: throwsA(isA<FormatException>().having((e) => e.message,
              'message', 'Positive input exceeds the limit of integer')),
        ),
      ];
      for (final intValueTest in intValueTests) {
        final tokenizer = Tokenizer(intValueTest.input);
        final tokens = tokenizer.tokenize();
        final token = tokens.first;
        if (intValueTest.want case final want?) {
          expect(token.intValue, want);
        }
        if (intValueTest.wantErr case final wantErr?) {
          expect(() => token.intValue, wantErr);
        }
      }
    });

    test('string token values', () {
      final stringValueTests = <_StringValueTest>[
        (
          input: '""',
          want: '',
          wantErr: null,
        ),
        (
          input: '"hello"',
          want: 'hello',
          wantErr: null,
        ),
        (
          input: r'"a\n\r\t\\\0b"',
          want: 'a\n\r\t\\\x00b',
          wantErr: null,
        ),
        (
          input: r'"a\"b"',
          want: 'a"b',
          wantErr: null,
        ),
        (
          input: r'''"a\'b"''',
          want: 'a\'b',
          wantErr: null,
        ),
        (
          input: r'"a\x00b"',
          want: 'a\x00b',
          wantErr: null,
        ),
        (
          input: r'"a\x7fb"',
          want: 'a\x7fb',
          wantErr: null,
        ),
        (
          input: r'"a\x80b"',
          want: null,
          wantErr: throwsA(isA<StringScannerException>()
              .having((e) => e.message, 'message', 'Bad hex escape sequence')),
        ),
        (
          input: r'"a\u{A}b"',
          want: 'a\u000ab',
          wantErr: null,
        ),
        (
          input: r'"a\u{aB}b"',
          want: 'a\u00abb',
          wantErr: null,
        ),
        (
          input: r'"a\u{AbC}b"',
          want: 'a\u0abcb',
          wantErr: null,
        ),
        (
          input: r'"a\u{aBcD}b"',
          want: 'a\uabcdb',
          wantErr: null,
        ),
        (
          input: r'"a\u{AbCdE}b"',
          want: 'a\u{abcde}b',
          wantErr: null,
        ),
        (
          input: r'"a\u{10cDeF}b"',
          want: 'a\u{10cdef}b',
          wantErr: null,
        ),
        (
          input: r'"a\u{ffffff}b"',
          want: null,
          wantErr: throwsA(isA<StringScannerException>().having(
              (e) => e.message, 'message', 'Bad unicode escape sequence')),
        ),
        (
          input: r'"a\u{d7ff}b"',
          want: 'a\ud7ffb',
          wantErr: null,
        ),
        (
          input: r'"a\u{d800}b"',
          want: null,
          wantErr: throwsA(isA<StringScannerException>().having(
              (e) => e.message, 'message', 'Bad unicode escape sequence')),
        ),
        (
          input: r'"a\u{dfff}b"',
          want: null,
          wantErr: throwsA(isA<StringScannerException>().having(
              (e) => e.message, 'message', 'Bad unicode escape sequence')),
        ),
        (
          input: r'"a\u{e000}b"',
          want: 'a\ue000b',
          wantErr: null,
        ),
        (
          input: r'"a\u{10ffff}b"',
          want: 'a\u{10ffff}b',
          wantErr: null,
        ),
        (
          input: r'"a\u{110000}b"',
          want: null,
          wantErr: throwsA(isA<StringScannerException>().having(
              (e) => e.message, 'message', 'Bad unicode escape sequence')),
        ),
      ];
      for (final stringValueTest in stringValueTests) {
        final tokenizer = Tokenizer(stringValueTest.input);
        final tokens = tokenizer.tokenize();
        final token = tokens.first;
        if (stringValueTest.want case final want?) {
          expect(token.stringValue, want);
        }
        if (stringValueTest.wantErr case final wantErr?) {
          expect(() => token.stringValue, wantErr);
        }
      }
    });
  });
}

typedef _ErrorTest = ({
  String input,
  String message,
  (int, int) position,
});

typedef _IntValueTest = ({
  String input,
  Int64? want,
  Matcher? wantErr,
});

typedef _StringValueTest = ({
  String input,
  String? want,
  Matcher? wantErr,
});
