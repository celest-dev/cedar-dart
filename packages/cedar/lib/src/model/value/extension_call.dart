part of '../value.dart';

final class ExtensionCall extends Value {
  const ExtensionCall({
    required this.fn,
    required this.arg,
  });

  factory ExtensionCall.fromJson(Map<String, Object?> json) {
    if (json
        case {
          '__extn': {
            'fn': final String fn,
            'arg': final Object? arg,
          }
        }) {
      return ExtensionCall(
        fn: fn,
        arg: Value.fromJson(arg),
      );
    }
    throw FormatException('Invalid Cedar extension call: $json');
  }

  factory ExtensionCall.fromProto(pb.ExtensionCall extensionCall) {
    return ExtensionCall(
      fn: extensionCall.fn,
      arg: Value.fromProto(extensionCall.arg),
    );
  }

  final String fn;
  final Value arg;

  @override
  Map<String, Object?> toJson() => {
        'fn': fn,
        'arg': arg.toJson(),
      };

  @override
  pb.Value toProto() => pb.Value(
        extensionCall: pb.ExtensionCall(
          fn: fn,
          arg: arg.toProto(),
        ),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionCall && fn == other.fn && arg == other.arg;

  @override
  int get hashCode => Object.hash(fn, arg);
}
