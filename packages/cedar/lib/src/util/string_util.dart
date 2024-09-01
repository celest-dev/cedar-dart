import 'package:string_scanner/string_scanner.dart';

import 'character.dart';

extension StringUtil on String {
  String unquoted({bool star = false}) {
    final scanner = StringScanner(this);
    return scanner.readUnquoted(star: star);
  }
}

extension StringScannerUtil on StringScanner {
  String readUnquoted({bool star = false}) {
    final buffer = StringBuffer();
    while (!isDone) {
      var ch = peekChar()!;
      if (star && ch == Character.star) {
        return buffer.toString();
      }
      ch = readChar();
      if (ch != Character.backslash) {
        buffer.writeCharCode(ch);
        continue;
      }
      ch = readChar();
      switch (ch) {
        case Character.lowerAlphaN:
          buffer.writeCharCode(Character.lineFeed);
        case Character.lowerAlphaR:
          buffer.writeCharCode(Character.carriageReturn);
        case Character.lowerAlphaT:
          buffer.writeCharCode(Character.tab);
        case Character.backslash:
          buffer.writeCharCode(Character.backslash);
        case Character.zero:
          buffer.writeCharCode(Character.nullChar);
        case Character.singleQuote:
          buffer.writeCharCode(Character.singleQuote);
        case Character.doubleQuote:
          buffer.writeCharCode(Character.doubleQuote);
        case Character.lowerAlphaX:
          ch = _parseHexEscape();
          buffer.writeCharCode(ch);
        case Character.lowerAlphaU:
          ch = _parseUnicodeEscape();
          buffer.writeCharCode(ch);
        case Character.star:
          if (!star) {
            error('Bad character escape');
          }
          buffer.writeCharCode(Character.star);
        default:
          error('Bad character escape');
      }
    }
    return buffer.toString();
  }
}

extension on StringScanner {
  int _parseHexEscape() {
    var value = 0;
    for (var i = 0; i < 2; i++) {
      final ch = Character(readChar());
      if (!ch.isValidHex) {
        error('Bad hex escape sequence');
      }
      value = value * 16 + ch.digitValue;
    }
    if (value > 0x7F) {
      error('Bad hex escape sequence');
    }
    return value;
  }

  int _parseUnicodeEscape() {
    if (readChar() != Character.leftCurlyBrace) {
      throw FormatException('Bad unicode escape sequence');
    }
    var value = 0, digits = 0;
    Character ch;
    while ((ch = Character(readChar())) != Character.rightCurlyBrace) {
      if (!ch.isValidHex) {
        error('Bad unicode escape sequence');
      }
      value = value * 16 + ch.digitValue;
      digits++;
    }
    if (digits == 0 || digits > 6 || !Character(value).isValueUtf8Rune) {
      error('Bad unicode escape sequence');
    }
    return value;
  }
}
