import 'package:cedar/cedar.dart';
import 'package:cedar/src/util/character.dart';
import 'package:cedar/src/util/string_util.dart';
import 'package:collection/collection.dart';
import 'package:string_scanner/string_scanner.dart';

CedarPattern pattern(List<Object?> components) {
  return CedarPattern.from(components);
}

final class CedarPattern {
  const CedarPattern(this.comps, {this.raw});

  factory CedarPattern.parse(String pattern) {
    final components = <CedarPatternComponent>[];
    final scanner = StringScanner(pattern);
    while (!scanner.isDone) {
      while (!scanner.isDone && scanner.peekChar() == Character.star) {
        scanner.readChar();
        components.add(Wildcard());
      }
      final literal = scanner.readUnquoted(star: true);
      if (literal.isNotEmpty) {
        components.add(Literal(literal));
      }
    }
    return CedarPattern.from(components, raw: pattern);
  }

  factory CedarPattern.from(List<Object?> components, {String? raw}) {
    final comps = <CedarPatternComponent>[];
    for (final comp in components) {
      switch (comp) {
        case Literal(literal: final String value) ||
              final String value ||
              StringValue(:final value):
          final component = switch (comps.lastOrNull) {
            null || Wildcard() => Literal(value),
            Literal() => Literal(comps.removeLast().literal + value),
          };
          comps.add(component);
        case Wildcard():
          if (comps.isEmpty || comps.last.literal.isNotEmpty) {
            comps.add(Wildcard());
          }
        default:
          throw ArgumentError.value(
            comp,
            'components',
            'must be a String or Wildcard',
          );
      }
    }
    return CedarPattern(comps, raw: raw);
  }

  final List<CedarPatternComponent> comps;
  final String? raw;

  String toCedar() => '"${toString(returnRaw: false)}"';

  bool match(String arg) {
    for (var i = 0; i < comps.length; i++) {
      final comp = comps[i];
      final lastChunk = i == comps.length - 1;
      if (comp is Wildcard && comp.literal.isEmpty) {
        return true;
      }
      var t = _matchChunk(comp.literal, arg);
      if (t != null && (t.isEmpty || !lastChunk)) {
        arg = t;
        continue;
      }
      if (comp is Wildcard) {
        for (var i = 0; i < arg.length; i++) {
          t = _matchChunk(comp.literal, arg.substring(i + 1));
          if (t != null) {
            if (lastChunk && t.isNotEmpty) {
              continue;
            }
            arg = t;
            continue;
          }
        }
      }
      return false;
    }
    return arg.isEmpty;
  }

  String? _matchChunk(String chunk, String s) {
    for (var i = 0; i < chunk.length; i++) {
      if (s.isEmpty) {
        return null;
      }
      if (chunk[i] != s[i]) {
        return null;
      }
      s = s.substring(1);
      chunk = chunk.substring(1);
    }
    return s;
  }

  @override
  String toString({bool returnRaw = true}) {
    if (raw case final raw? when returnRaw) {
      return raw;
    }
    final buf = StringBuffer();
    for (final comp in comps) {
      if (comp is Wildcard) {
        buf.writeCharCode(Character.star);
      }
      for (final char in comp.literal.runes) {
        final escaped = switch (char) {
          Character.nullChar => '\\0'.codeUnits,
          Character.tab => '\\t'.codeUnits,
          Character.lineFeed => '\\n'.codeUnits,
          Character.carriageReturn => '\\r'.codeUnits,
          Character.doubleQuote => '\\"'.codeUnits,
          Character.singleQuote => "\\'".codeUnits,
          Character.star => '\\*'.codeUnits,
          < 0x20 ||
          0x7f ||
          0x96 ||
          > 0xffff =>
            '\\u{${char.toRadixString(16)}}'.codeUnits,
          _ => [char],
        };
        escaped.forEach(buf.writeCharCode);
      }
    }
    return buf.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarPattern &&
          const ListEquality<CedarPatternComponent>()
              .equals(comps, other.comps);

  @override
  int get hashCode => Object.hashAll(comps);
}

sealed class CedarPatternComponent {
  const CedarPatternComponent();

  String get literal;
}

final class Wildcard extends CedarPatternComponent {
  const Wildcard([this.literal = '']);

  @override
  final String literal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Wildcard && literal == other.literal;

  @override
  int get hashCode => Object.hash(Wildcard, literal);
}

final class Literal extends CedarPatternComponent {
  const Literal(this.literal);

  @override
  final String literal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Literal && literal == other.literal;

  @override
  int get hashCode => Object.hash(Literal, literal);
}
