import 'package:cedar/ast.dart';
import 'package:cedar/src/util/character.dart';
import 'package:cedar/src/util/string_util.dart';
import 'package:collection/collection.dart';
import 'package:string_scanner/string_scanner.dart';

CedarPattern pattern(List<Object?> components) {
  return CedarPattern.from(components);
}

final class CedarPattern {
  const CedarPattern(this.comps, {this.raw, this.jsonForm});

  factory CedarPattern.parse(String pattern) {
    final components = <Object?>[];
    final jsonComponents = <Object?>[];
    final scanner = StringScanner(pattern);
    while (!scanner.isDone) {
      while (!scanner.isDone && scanner.peekChar() == Character.star) {
        scanner.readChar();
        components.add(const Wildcard());
        jsonComponents.add('Wildcard');
      }
      final literal = scanner.readUnquoted(star: true);
      if (literal.isNotEmpty) {
        components.add(Literal(literal));
        for (final rune in literal.runes) {
          jsonComponents.add({'Literal': String.fromCharCode(rune)});
        }
      }
    }
    return CedarPattern.from(
      components,
      raw: pattern,
      jsonForm: jsonComponents,
    );
  }

  factory CedarPattern.from(
    List<Object?> components, {
    String? raw,
    List<Object?>? jsonForm,
  }) {
    String? literalAccumulator;
    final comps = <CedarPatternComponent>[];

    void flushLiteral() {
      if (literalAccumulator case final literal? when literal.isNotEmpty) {
        if (comps.isNotEmpty && comps.last is Literal) {
          final previous = comps.removeLast() as Literal;
          literalAccumulator = '${previous.literal}$literal';
        }
        comps.add(Literal(literalAccumulator!));
      }
      literalAccumulator = null;
    }

    void pushLiteral(String literal) {
      literalAccumulator = '${literalAccumulator ?? ''}$literal';
    }

    void pushWildcard() {
      flushLiteral();
      if (comps.isEmpty || comps.last.literal.isNotEmpty) {
        comps.add(const Wildcard());
      }
    }

    for (final comp in components) {
      switch (comp) {
        case Literal(literal: final String value):
          pushLiteral(value);
        case Wildcard():
          pushWildcard();
        case StringValue(:final value):
          pushLiteral(value);
        case final String value:
          if (value == 'Wildcard') {
            pushWildcard();
          } else {
            pushLiteral(value);
          }
        case Map<Object?, Object?> map:
          if (map.length != 1) {
            throw ArgumentError.value(
              map,
              'components',
              'pattern component map must contain exactly one entry',
            );
          }
          final entry = map.entries.first;
          switch (entry.key) {
            case 'Literal':
              final literal = entry.value;
              if (literal is! String) {
                throw ArgumentError.value(
                  entry.value,
                  'components',
                  'Literal component must be a string',
                );
              }
              pushLiteral(literal);
            case 'Wildcard':
              pushWildcard();
            default:
              throw ArgumentError.value(
                entry.key,
                'components',
                'Unknown pattern component type',
              );
          }
        default:
          throw ArgumentError.value(
            comp,
            'components',
            'must describe a literal or wildcard',
          );
      }
    }
    flushLiteral();
    return CedarPattern(
      comps,
      raw: raw,
      jsonForm: jsonForm == null
          ? null
          : List<Object?>.unmodifiable(
              jsonForm.map(_clonePatternJsonComponent),
            ),
    );
  }

  final List<CedarPatternComponent> comps;
  final String? raw;
  final List<Object?>? jsonForm;

  String toCedar() => '"${toString(returnRaw: false)}"';

  bool match(String arg) => _buildRegExp().hasMatch(arg);

  RegExp _buildRegExp() {
    final buffer = StringBuffer('^');
    for (final comp in comps) {
      if (comp is Wildcard) {
        buffer.write('.*');
      } else {
        buffer.write(RegExp.escape(comp.literal));
      }
    }
    buffer.write(r'$');
    return RegExp(buffer.toString(), dotAll: true);
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
          > 0xffff => '\\u{${char.toRadixString(16)}}'.codeUnits,
          _ => [char],
        };
        escaped.forEach(buf.writeCharCode);
      }
    }
    return buf.toString();
  }

  /// Encode pattern components in the same shape as the Rust EST (`Vec<PatternElem>`) format.
  List<Object?> toJson() {
    if (jsonForm case final json?) {
      return json;
    }
    final encoded = <Object?>[];
    for (final comp in comps) {
      if (comp is Wildcard) {
        encoded.add('Wildcard');
        continue;
      }
      for (final rune in comp.literal.runes) {
        encoded.add({'Literal': String.fromCharCode(rune)});
      }
    }
    return encoded;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarPattern &&
          const ListEquality<CedarPatternComponent>().equals(
            comps,
            other.comps,
          );

  @override
  int get hashCode => Object.hashAll(comps);
}

Object? _clonePatternJsonComponent(Object? value) {
  if (value is List<Object?>) {
    return List<Object?>.unmodifiable(value.map(_clonePatternJsonComponent));
  }
  if (value is Map) {
    final mapped = value.map((key, val) {
      if (key is! String) {
        throw ArgumentError.value(key, 'component key', 'must be a string');
      }
      return MapEntry(key, _clonePatternJsonComponent(val));
    });
    return Map<String, Object?>.unmodifiable(mapped);
  }
  return value;
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
