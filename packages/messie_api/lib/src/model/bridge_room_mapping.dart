//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bridge_room_mapping.g.dart';

/// BridgeRoomMapping
///
/// Properties:
/// * [provider] 
/// * [roomId] 
/// * [loginId] 
/// * [loginName] 
/// * [spaceRoom] 
/// * [preferred] 
@BuiltValue()
abstract class BridgeRoomMapping implements Built<BridgeRoomMapping, BridgeRoomMappingBuilder> {
  @BuiltValueField(wireName: r'provider')
  String get provider;

  @BuiltValueField(wireName: r'room_id')
  String get roomId;

  @BuiltValueField(wireName: r'login_id')
  String get loginId;

  @BuiltValueField(wireName: r'login_name')
  String? get loginName;

  @BuiltValueField(wireName: r'space_room')
  String? get spaceRoom;

  @BuiltValueField(wireName: r'preferred')
  bool? get preferred;

  BridgeRoomMapping._();

  factory BridgeRoomMapping([void updates(BridgeRoomMappingBuilder b)]) = _$BridgeRoomMapping;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BridgeRoomMappingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BridgeRoomMapping> get serializer => _$BridgeRoomMappingSerializer();
}

class _$BridgeRoomMappingSerializer implements PrimitiveSerializer<BridgeRoomMapping> {
  @override
  final Iterable<Type> types = const [BridgeRoomMapping, _$BridgeRoomMapping];

  @override
  final String wireName = r'BridgeRoomMapping';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BridgeRoomMapping object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    yield r'room_id';
    yield serializers.serialize(
      object.roomId,
      specifiedType: const FullType(String),
    );
    yield r'login_id';
    yield serializers.serialize(
      object.loginId,
      specifiedType: const FullType(String),
    );
    if (object.loginName != null) {
      yield r'login_name';
      yield serializers.serialize(
        object.loginName,
        specifiedType: const FullType(String),
      );
    }
    if (object.spaceRoom != null) {
      yield r'space_room';
      yield serializers.serialize(
        object.spaceRoom,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.preferred != null) {
      yield r'preferred';
      yield serializers.serialize(
        object.preferred,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BridgeRoomMapping object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BridgeRoomMappingBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'room_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.roomId = valueDes;
          break;
        case r'login_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.loginId = valueDes;
          break;
        case r'login_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.loginName = valueDes;
          break;
        case r'space_room':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.spaceRoom = valueDes;
          break;
        case r'preferred':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.preferred = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BridgeRoomMapping deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BridgeRoomMappingBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

