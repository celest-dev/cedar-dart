import 'package:cedar/ast.dart';
import 'package:cedar/cedar.dart';
import 'package:cedar/src/ast.dart' as ast;
import 'package:test/test.dart';

void main() {
  test('examples', () {
    final johnny = CedarEntityId('User', 'johnny');
    final sow = CedarEntityId('Action', 'sow');
    final cast = CedarEntityId('Action', 'cast');

    // @example("one")
    // permit (
    //   principal == User::"johnny",
    //   action in [Action::"sow", Action::"cast"],
    //   resource
    // )
    // when { true }
    // unless { false };
    {
      final _ = ast
          .annotation('example', 'one')
          .permit()
          .principalIsIn('User', johnny)
          .actionInSet({sow, cast})
          .when(ast.true_())
          .unless(ast.false_());
    }

    // @example("two")
    // forbid (principal, action, resource)
    // when { resource.tags.contains("private") }
    // unless { resource in principal.allowed_resources };
    {
      final _ = ast
          .annotation('example', 'two')
          .forbid()
          .when(ast.resource().access('tags').contains(ast.string('private')))
          .unless(
            ast.resource().in_(ast.principal().access('allowed_resources')),
          );
    }

    // forbid (principal, action, resource)
    // when { {x: "value"}.x == "value" }
    // when { {x: 1 + context.fooCount}.x == 3 }
    // when { [1, (2 + 3) * 4, context.fooCount].contains(1) };
    {
      final _ = ast
          .forbid()
          .when(
            ast
                .record({('x', ast.string('value'))})
                .access('x')
                .equals(ast.string('value')),
          )
          .when(
            ast
                .record({('x', ast.long(1) + ast.context().access('fooCount'))})
                .access('x')
                .equals(ast.long(3)),
          )
          .when(
            ast.set([
              ast.long(1),
              (ast.long(2) + ast.long(3)) * ast.long(4),
              ast.context().access('fooCount'),
            ]).contains(ast.long(1)),
          );
    }
  });
}
