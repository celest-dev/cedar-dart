import 'package:cedar/src/proto/cedar/v3/expr.pb.dart' as pb;

enum CedarVariable {
  principal,
  action,
  resource,
  context;

  factory CedarVariable.fromProto(pb.Variable variable) {
    return switch (variable) {
      pb.Variable.VARIABLE_PRINCIPAL => CedarVariable.principal,
      pb.Variable.VARIABLE_ACTION => CedarVariable.action,
      pb.Variable.VARIABLE_RESOURCE => CedarVariable.resource,
      pb.Variable.VARIABLE_CONTEXT => CedarVariable.context,
      _ => throw FormatException('Invalid Cedar variable: ${variable.name}'),
    };
  }

  pb.Variable toProto() => switch (this) {
        principal => pb.Variable.VARIABLE_PRINCIPAL,
        action => pb.Variable.VARIABLE_ACTION,
        resource => pb.Variable.VARIABLE_RESOURCE,
        context => pb.Variable.VARIABLE_CONTEXT,
      };
}
