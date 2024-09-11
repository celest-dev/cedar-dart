import 'dart:collection';

import 'package:cedar/ast.dart';
import 'package:cedar/src/proto/cedar/v3/policy.pb.dart' as pb;
import 'package:collection/collection.dart';

final class Annotations with IterableMixin<Annotation> {
  Annotations(this.annotations);

  factory Annotations.fromJson(Map<String, Object?> json) {
    return Annotations(json.cast());
  }

  factory Annotations.fromProto(pb.Annotations annotations) {
    return Annotations(annotations.annotations);
  }

  final Map<String, String> annotations;

  operator [](String key) => annotations[key];
  operator []=(String key, String value) => annotations[key] = value;

  void add(Annotation annotation) {
    annotations[annotation.key] = annotation.value;
  }

  Annotations annotation(String key, String value) {
    return Annotations({
      ...annotations,
      key: value,
    });
  }

  Policy permit() {
    return Policy(effect: Effect.permit, annotations: this);
  }

  Policy forbid() {
    return Policy(effect: Effect.forbid, annotations: this);
  }

  Iterable<Annotation> get iterable sync* {
    for (final entry in annotations.entries) {
      yield (key: entry.key, value: entry.value);
    }
  }

  @override
  Iterator<Annotation> get iterator => iterable.iterator;

  Map<String, String> toJson() => annotations;

  pb.Annotations toProto() {
    return pb.Annotations(annotations: annotations);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Annotations &&
          const MapEquality().equals(annotations, other.annotations);

  @override
  int get hashCode => const MapEquality().hash(annotations);
}

Annotations annotation(String key, String value) {
  return Annotations({key: value});
}

typedef Annotation = ({String key, String value});
