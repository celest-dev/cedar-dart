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

    test('parses entity tags clause', () {
      const schemaSource = r'''
entity Foo tags {
  decimal: __cedar::decimal,
};
''';

      final schema = CedarSchema.parse(schemaSource);
      final json = schema.toJson();
      expect(json[''], isNotNull);
      final entity =
          (json[''] as Map<String, Object?>)['entityTypes']
              as Map<String, Object?>;
      expect(entity['Foo'], isNotNull);
      final tags =
          (entity['Foo']! as Map<String, Object?>)['tags']
              as Map<String, Object?>;
      expect(tags, {
        'type': 'Record',
        'attributes': {
          'decimal': {'type': 'Extension', 'name': 'decimal'},
        },
      });
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

  group('CedarSchema.toJson', () {
    test('normalizes entity UIDs on request', () {
      const rawActionId = '\u0005';
      const normalizedActionId = r'\u{5}';

      final schema = CedarSchema.fromJson({
        '': {
          'actions': {
            rawActionId: {
              'memberOf': [
                {'type': 'Action', 'id': rawActionId},
              ],
            },
          },
        },
      });

      final defaultActions =
          (schema.toJson()['']! as Map<String, Object?>)['actions']!
              as Map<String, Object?>;
      final defaultMemberOf =
          (defaultActions[rawActionId]! as Map<String, Object?>)['memberOf']!
              as List<Object?>;
      expect(defaultMemberOf.first, {'type': 'Action', 'id': rawActionId});

      final normalizedActions =
          (schema.toJson(normalizedUids: true)['']!
                  as Map<String, Object?>)['actions']!
              as Map<String, Object?>;
      expect(normalizedActions.containsKey(rawActionId), isFalse);
      expect(normalizedActions.containsKey(normalizedActionId), isTrue);

      final normalizedMemberOf =
          (normalizedActions[normalizedActionId]!
                  as Map<String, Object?>)['memberOf']!
              as List<Object?>;
      expect(normalizedMemberOf.first, {
        'type': 'Action',
        'id': normalizedActionId,
      });
    });
  });
}
