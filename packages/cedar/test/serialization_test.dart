import 'package:cedar/cedar.dart';
import 'package:test/test.dart';

void main() {
  group('serialization', () {
    test('extension call JSON matches Cedar spec', () {
      final value = Value.extensionCall(
        fn: 'decimal.lessThan',
        arg: const Value.string('1'),
      );

      final json = value.toJson();
      expect(json, {
        '__extn': {'fn': 'decimal.lessThan', 'arg': '1'},
      });

      final roundTrip = Value.fromJson(json);
      expect(roundTrip, equals(value));
    });

    test('template link JSON encodes entity UIDs canonically', () {
      const entityUid = EntityUid.of('User', 'alice');
      final link = TemplateLink(
        templateId: 'photoTemplate',
        newId: 'allowAlice',
        values: {SlotId.principal: entityUid},
      );

      final json = link.toJson();
      expect(json, {
        'templateId': 'photoTemplate',
        'newId': 'allowAlice',
        'values': {
          '?principal': {'type': 'User', 'id': 'alice'},
        },
      });

      final roundTrip = TemplateLink.fromJson(json);
      expect(roundTrip, equals(link));
    });

    test('entity UID normalization matches Rust escape rules', () {
      final trickyId = String.fromCharCodes([
        0x5c,
        0x5c,
        0x5c,
        0x5c,
        0x5c,
        0x36,
        0x4a,
      ]);
      final normalized = EntityUid.of('a', trickyId).normalized;

      final expectedId = trickyId.replaceAll('\\', r'\\');
      expect(normalized.id, equals(expectedId));
      expect(normalized.toString(), equals('a::"$expectedId"'));
    });

    test('entity UID normalization escapes non-ascii characters', () {
      final raw = String.fromCharCodes([0x0a, 0x0d, 0x031d, 0xa0, 0xa1]);
      final normalized = EntityUid.of('a', raw).normalized;
      expect(normalized.id, equals(r'\n\r\u{31d}\u{a0}¡'));
    });

    test('entity UID normalization escapes null bytes and retains ascii', () {
      final raw = String.fromCharCodes([
        0x00,
        0x00,
        0x40,
        0x7a,
        0x0694,
        0x0694,
        0x00,
      ]);
      final normalized = EntityUid.of('a', raw).normalized;
      expect(normalized.id, equals(r'\0\0@zڔڔ\0'));
      expect(normalized.toString(), equals('a::"\\0\\0@zڔڔ\\0"'));
    });

    test(
      'entity JSON normalization canonicalizes nested entity references',
      () {
        final raw = String.fromCharCodes([
          0x00,
          0x00,
          0x40,
          0x7a,
          0x0694,
          0x0694,
          0x00,
        ]);
        final normalizedId = r'\0\0@zڔڔ\0';

        final primary = EntityUid.of('a', raw);
        final parent = EntityUid.of('parent::Type', raw);

        final entity = Entity(
          uid: primary,
          parents: [parent],
          attributes: {
            'direct': Value.entity(uid: primary),
            'set': Value.set([
              Value.entity(uid: primary),
              Value.record({'inner': Value.entity(uid: parent)}),
            ]),
          },
          tags: {'tagged': Value.entity(uid: parent)},
        );

        final defaultJson = entity.toJson();
        expect(defaultJson['uid'], equals({'type': 'a', 'id': raw}));

        final normalizedJson = entity.toJson(normalizedUids: true);
        expect(
          normalizedJson['uid'],
          equals({'type': 'a', 'id': normalizedId}),
        );
        expect(
          normalizedJson['parents'],
          equals([
            {'type': 'parent::Type', 'id': normalizedId},
          ]),
        );

        final attrs = (normalizedJson['attrs']! as Map<String, Object?>)
            .cast<String, Object?>();
        expect(
          attrs['direct'],
          equals({
            '__entity': {'type': 'a', 'id': normalizedId},
          }),
        );

        final setValue = (attrs['set']! as List<Object?>).cast<Object?>();
        expect(
          setValue.first,
          equals({
            '__entity': {'type': 'a', 'id': normalizedId},
          }),
        );
        final record = (setValue.last! as Map<String, Object?>)
            .cast<String, Object?>();
        expect(
          record['inner'],
          equals({
            '__entity': {'type': 'parent::Type', 'id': normalizedId},
          }),
        );

        final tags = (normalizedJson['tags']! as Map<String, Object?>)
            .cast<String, Object?>();
        expect(
          tags['tagged'],
          equals({
            '__entity': {'type': 'parent::Type', 'id': normalizedId},
          }),
        );
      },
    );

    test('policy JSON normalization rewrites action entity ids', () {
      final rawActionId = String.fromCharCode(0x05);
      const normalizedActionId = r'\u{5}';

      final policy = Policy(
        effect: Effect.permit,
        action: ActionEquals(EntityUid.of('Action', rawActionId)),
      );
      final policySet = PolicySet(policies: {'p': policy});

      final defaultJson = policySet.toJson();
      final defaultPolicy =
          ((defaultJson['staticPolicies']! as Map<String, Object?>)['p']!
                  as Map<String, Object?>)
              .cast<String, Object?>();
      final defaultAction = (defaultPolicy['action']! as Map<String, Object?>)
          .cast<String, Object?>();
      final defaultEntity = (defaultAction['entity']! as Map<String, Object?>)
          .cast<String, Object?>();
      expect(defaultEntity['id'], equals(rawActionId));

      final normalizedJson = policySet.toJson(normalizedUids: true);
      final normalizedPolicy =
          ((normalizedJson['staticPolicies']! as Map<String, Object?>)['p']!
                  as Map<String, Object?>)
              .cast<String, Object?>();
      final normalizedAction =
          (normalizedPolicy['action']! as Map<String, Object?>)
              .cast<String, Object?>();
      final normalizedEntity =
          (normalizedAction['entity']! as Map<String, Object?>)
              .cast<String, Object?>();
      expect(normalizedEntity['id'], equals(normalizedActionId));
    });
  });
}
