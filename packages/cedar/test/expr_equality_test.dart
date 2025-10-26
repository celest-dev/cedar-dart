import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

void main() {
  group('Expr equality', () {
    const user = EntityUid.of('User', 'alice');
    const group = EntityUid.of('Group', 'eng');

    final cases = <String, Expr Function()>{
      'value expression': () => Expr.value(Value.bool(true)),
      'variable expression': () => Expr.variable(CedarVariable.context),
      'slot expression': () => Expr.slot(SlotId.resource),
      'unknown expression': () => Expr.unknown('mystery'),
      'not expression': () => Expr.not(Expr.variable(CedarVariable.principal)),
      'negate expression': () => Expr.negate(Expr.value(Value.long(Int64(42)))),
      'equals expression': () => Expr.equals(
        left: Expr.variable(CedarVariable.action),
        right: Expr.variable(CedarVariable.resource),
      ),
      'contains expression': () => Expr.contains(
        left: Expr.value(Value.set([Value.bool(true), Value.bool(false)])),
        right: Expr.value(Value.bool(true)),
      ),
      'get attribute expression': () => Expr.getAttribute(
        left: Expr.variable(CedarVariable.resource),
        attr: 'owner',
      ),
      'has attribute expression': () => Expr.hasAttribute(
        left: Expr.variable(CedarVariable.resource),
        attr: 'owner',
      ),
      'get tag expression': () => Expr.getTag(
        left: Expr.value(Value.entity(uid: user)),
        tag: Expr.value(Value.string('department')),
      ),
      'has tag expression': () => Expr.hasTag(
        left: Expr.value(Value.entity(uid: user)),
        tag: Expr.value(Value.string('department')),
      ),
      'like expression': () => Expr.like(
        left: Expr.variable(CedarVariable.principal),
        pattern: CedarPattern.parse('foo*'),
      ),
      'is expression': () => Expr.is_(
        left: Expr.value(Value.entity(uid: user)),
        entityType: 'User',
        inExpr: Expr.set([Expr.value(Value.entity(uid: group))]),
      ),
      'if-then-else expression': () => Expr.ifThenElse(
        cond: Expr.equals(
          left: Expr.variable(CedarVariable.principal),
          right: Expr.variable(CedarVariable.resource),
        ),
        then: Expr.value(Value.bool(true)),
        otherwise: Expr.value(Value.bool(false)),
      ),
      'set expression': () => Expr.set([
        Expr.value(Value.bool(true)),
        Expr.value(Value.bool(false)),
      ]),
      'record expression': () => Expr.record({
        'foo': Expr.value(Value.bool(true)),
        'bar': Expr.variable(CedarVariable.context),
      }),
      'extension call expression': () => Expr.extensionCall(
        fn: 'ip',
        args: [Expr.value(Value.string('127.0.0.1'))],
      ),
    };

    cases.forEach((description, build) {
      test(description, () {
        final first = build();
        final second = build();

        expect(first, equals(second));
        expect(second, equals(first));
      });
    });

    test('set expressions ignore element order', () {
      final first = Expr.set([
        Expr.value(Value.bool(true)),
        Expr.value(Value.bool(false)),
      ]);
      final second = Expr.set([
        Expr.value(Value.bool(false)),
        Expr.value(Value.bool(true)),
      ]);

      expect(first, equals(second));
    });

    test('record expressions compare by attribute content', () {
      final first = Expr.record({
        'foo': Expr.value(Value.bool(true)),
        'bar': Expr.variable(CedarVariable.context),
      });
      final second = Expr.record({
        'bar': Expr.variable(CedarVariable.context),
        'foo': Expr.value(Value.bool(true)),
      });

      expect(first, equals(second));
    });
  });
}
