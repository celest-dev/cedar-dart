import 'package:cedar/cedar.dart';
import 'package:cedar/src/parser/schema_parser.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final buffer = StringBuffer()
      ..write('[${record.level.name}] ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      buffer.write(' error: ${record.error}');
    }
    if (record.stackTrace != null) {
      buffer.write('\n${record.stackTrace}');
    }
    // ignore: avoid_print
    print(buffer.toString());
  });

  group('CedarSchema.parse', () {
    test('parses human-readable schema and validates references', () {
      const schemaSource = r'''
namespace HR {
  entity Human;
  entity Group;

  type Tags = {
    level: Long,
  };

  entity User in [Human] = {
    id: String,
    manager?: User,
    tags: Tags,
    groups: Set<Group>,
  };

  action viewProfile in [Group::"hr"] appliesTo {
    principal: [User],
    resource: [Human],
    context: Tags,
  };
}
''';

      final schema = CedarSchema.parse(schemaSource);
      final expected = {
        'HR': {
          'entityTypes': {
            'Human': {},
            'Group': {},
            'User': {
              'memberOfTypes': ['HR::Human'],
              'shape': {
                'type': 'Record',
                'attributes': {
                  'id': {'type': 'String'},
                  'manager': {
                    'type': 'Entity',
                    'name': 'HR::User',
                    'required': false,
                  },
                  'tags': {'type': 'Tags'},
                  'groups': {
                    'type': 'Set',
                    'element': {'type': 'Entity', 'name': 'HR::Group'},
                  },
                },
              },
            },
          },
          'actions': {
            'viewProfile': {
              'memberOf': [
                {'type': 'HR::Group', 'id': 'hr'},
              ],
              'appliesTo': {
                'principalTypes': ['HR::User'],
                'resourceTypes': ['HR::Human'],
                'context': {'type': 'Tags'},
              },
            },
          },
          'commonTypes': {
            'Tags': {
              'type': 'Record',
              'attributes': {
                'level': {'type': 'Long'},
              },
            },
          },
        },
      };

      final equality = const DeepCollectionEquality().equals;
      expect(equality(schema.toJson(), expected), isTrue);
      expect(() => schema.validate(), returnsNormally);
    });

    test('throws on unknown references during parse', () {
      const schemaSource = 'entity Foo = { bar: Missing };';
      expect(
        () => CedarSchema.parse(schemaSource),
        throwsA(isA<SchemaValidationException>()),
      );
    });
  });

  group('CedarSchema.validate', () {
    test('detects invalid references in JSON schema', () {
      final schema = CedarSchema.fromJson({
        '': {
          'entityTypes': {
            'User': {
              'shape': {
                'type': 'Record',
                'attributes': {
                  'manager': {'type': 'Entity', 'name': 'Unknown::User'},
                },
              },
            },
          },
        },
      });

      expect(schema.validate, throwsA(isA<SchemaValidationException>()));
    });

    test('detects non-record action context', () {
      final schema = CedarSchema.fromJson({
        '': {
          'entityTypes': {'User': {}, 'Document': {}},
          'actions': {
            'view': {
              'appliesTo': {
                'principalTypes': ['User'],
                'resourceTypes': ['Document'],
                'context': {'type': 'String'},
              },
            },
          },
        },
      });

      expect(
        schema.validate,
        throwsA(
          isA<SchemaValidationException>().having(
            (error) => error.message,
            'message',
            contains('Context for action view must be a record type'),
          ),
        ),
      );
    });

    test('detects recursive common type references', () {
      final schema = CedarSchema.fromJson({
        '': {
          'commonTypes': {
            'Loop': {'type': 'Loop'},
          },
        },
      });

      expect(
        schema.validate,
        throwsA(
          isA<SchemaValidationException>().having(
            (error) => error.message,
            'message',
            contains('Recursive type reference detected'),
          ),
        ),
      );
    });
  });
}
