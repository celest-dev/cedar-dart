part of 'cedar_value.dart';

@Deprecated('Use CedarExtensionCall instead')
typedef CedarValueExtension = CedarExtensionCall;

final class CedarExtensionCall extends CedarValue {
  const CedarExtensionCall({
    required this.fn,
    required this.arg,
  });

  factory CedarExtensionCall.fromJson(Map<String, Object?> json) {
    if (json
        case {
          '__extn': {
            'fn': final String fn,
            'arg': final Object? arg,
          }
        }) {
      return CedarExtensionCall(
        fn: fn,
        arg: CedarValue.fromJson(arg),
      );
    }
    throw FormatException('Invalid Cedar extension call: $json');
  }

  final String fn;
  final CedarValue arg;

  @override
  Map<String, Object?> toJson() => {
        'fn': fn,
        'arg': arg.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CedarExtensionCall && fn == other.fn && arg == other.arg;

  @override
  int get hashCode => Object.hash(fn, arg);
}
