import 'package:cedar/ast.dart';
import 'package:test/test.dart';

void main() {
  test('Expr.fromJson accepts like pattern components list', () {
    final expr = Expr.fromJson({
      'like': {
        'left': {'Var': 'resource'},
        'pattern': [
          'Wildcard',
          {'Literal': '@'},
          {'Literal': 'example'},
          {'Literal': '.'},
          {'Literal': 'com'},
        ],
      },
    });

    expect(expr, isA<ExprLike>());
    final like = expr as ExprLike;
    expect(like.pattern.toString(), '*@example.com');
  });
}
