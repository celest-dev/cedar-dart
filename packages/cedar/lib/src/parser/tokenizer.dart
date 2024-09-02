import 'package:cedar/src/util/character.dart';
import 'package:cedar/src/util/string_util.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

enum TokenType {
  eof,
  ident,
  int,
  string,
  operator,
  slot,
  unknown;
}

final class Token {
  const Token({
    required this.type,
    required this.span,
  });

  final TokenType type;
  final SourceSpan span;
  String get text => span.text;

  bool get isEof => type == TokenType.eof;
  bool get isIdent => type == TokenType.ident;
  bool get isInt => type == TokenType.int;
  bool get isString => type == TokenType.string;
  bool get isSlot => type == TokenType.slot;

  String get stringValue {
    final value =
        text.replaceAll(RegExp(r'^"'), '').replaceAll(RegExp(r'"$'), '');
    return value.unquoted(star: false);
  }

  Int64 get intValue {
    final value = Int64.parseInt(text);
    // Check for overflow. Since `text` is always a positive integer, we only
    // need to check for negative values.
    if (value < 0) {
      throw FormatException(
        'Positive input exceeds the limit of integer',
        text,
      );
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          type == other.type &&
          span.start == other.span.start &&
          span.end == other.span.end &&
          text == other.text;

  @override
  int get hashCode => Object.hash(type, span);

  @override
  String toString() =>
      'Token($type, $text, ${span.start.offset}-${span.end.offset})';
}

final class Tokenizer {
  Tokenizer(
    String source, {
    Uri? sourceUrl,
  }) : _scanner = _SpanScanner(SpanScanner(source, sourceUrl: sourceUrl));

  final _SpanScanner _scanner;

  SourceSpan span(int start, [int? end]) {
    return _scanner.spanFromPosition(start, end);
  }

  List<Token> tokenize() {
    final tokens = <Token>[];
    for (;;) {
      final token = next();
      tokens.add(token);
      if (token.isEof) {
        break;
      }
    }
    return tokens;
  }

  Token next() {
    _scanner.scanWhitespace();
    final startState = _scanner.state;
    final TokenType type;
    if (_scanner.isDone) {
      type = TokenType.eof;
    } else if (_scanner.scanSlot()) {
      type = TokenType.slot;
    } else if (_scanner.scanIdentifier()) {
      type = TokenType.ident;
    } else if (_scanner.scanInt()) {
      type = TokenType.int;
    } else if (_scanner.peekChar() == Character.doubleQuote) {
      _scanner.expectString();
      type = TokenType.string;
    } else if (_scanner.matchesComment()) {
      if (!_scanner.scanComment()) {
        _scanner.error('Comment not terminated');
      }
      return next();
    } else if (_scanner.scanOperator()) {
      type = TokenType.operator;
    } else {
      final cp = _scanner.readCodePoint();
      if (cp == 0) {
        _scanner.error('Invalid character NUL');
      }
      type = TokenType.unknown;
    }
    return Token(
      type: type,
      span: _scanner.spanFrom(startState),
    );
  }
}

extension type _SpanScanner(SpanScanner s) implements SpanScanner {
  @redeclare
  Character readCodePoint() => s.readCodePoint() as Character;

  @redeclare
  Character? peekCodePoint() => s.peekCodePoint() as Character?;

  static final RegExp _ident = RegExp(r'([a-zA-Z_][a-zA-Z0-9_]*)');
  static final RegExp _slot = RegExp(r'\?' + _ident.pattern);
  static final RegExp _int = RegExp(r'([0-9]+)');
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _escape = RegExp(r'''\\[nrt0\'\"\\\*]''');
  static final RegExp _hexEscape = RegExp(r'\\x([0-9a-fA-F]{2,})');
  static final RegExp _unicodeEscape = RegExp(r'\\u\{([0-9a-fA-F]{1,6})\}');
  static final RegExp _singleLineComment = RegExp(r'\/\/.*', multiLine: false);
  static final RegExp _multiLineComment =
      RegExp(r'\/\*.*\*\/', multiLine: true, dotAll: true);
  static final RegExp _operator =
      RegExp(r'[@\.,;\(\)\{\}\[\]\+\-*]|::?|<=?|>=?|==|!=?|\|\||&&');
  static final _commentStart = RegExp(r'\/(\/|\*)');

  bool matchesComment() => s.matches(_commentStart);

  String get lastScanned => s.lastMatch!.group(0)!;

  void scanWhitespace() => s.scan(_whitespace);
  bool scanSlot() => s.scan(_slot);
  bool scanIdentifier() => s.scan(_ident);
  bool scanInt() => s.scan(_int);
  String expectString() {
    s.expectChar(Character.doubleQuote);
    var start = s.position;
    Character? ch;
    while ((ch = peekCodePoint()) != Character.doubleQuote) {
      switch (ch) {
        case Character.lineFeed:
          s.error('Literal not terminated');
        case Character.backslash when s.scan(_escape):
          continue;
        case Character.backslash when s.scan(_hexEscape):
          continue;
        case Character.backslash when s.scan(_unicodeEscape):
          continue;
        case Character.backslash:
          s.error('Invalid character escape');
        default:
          s.readCodePoint();
      }
    }
    s.expectChar(Character.doubleQuote);
    return s.substring(start, s.position);
  }

  bool scanOperator() => s.scan(_operator);

  bool scanComment() {
    return s.scan(_singleLineComment) || s.scan(_multiLineComment);
  }
}
