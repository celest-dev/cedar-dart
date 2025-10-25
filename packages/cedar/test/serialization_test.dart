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
  });
}
