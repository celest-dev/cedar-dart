import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:cedar/cedar.dart';

part 'serializers.g.dart';

@SerializersFor([
  PolicySet,
])
final Serializers cedarSerializers =
    (_$cedarSerializers.toBuilder()..add(const EntityUidSerializer())).build();

final class EntityUidSerializer implements StructuredSerializer<EntityUid> {
  const EntityUidSerializer();

  @override
  EntityUid deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    late String type, id;
    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final name = iterator.current as String;
      final value = iterator.moveNext() ? iterator.current : null;
      switch (name) {
        case 'type':
          type = value as String;
        case 'id':
          id = value as String;
      }
    }
    return EntityUid.of(type, id);
  }

  @override
  Iterable<Object?> serialize(Serializers serializers, EntityUid object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[
      'type',
      object.type,
      'id',
      object.id,
    ];
  }

  @override
  Iterable<Type> get types => const [EntityUid];

  @override
  String get wireName => 'EntityUid';
}
