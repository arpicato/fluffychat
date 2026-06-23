//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_sticker_pack_request.g.dart';

/// CreateStickerPackRequest
///
/// Properties:
/// * [name] 
@BuiltValue()
abstract class CreateStickerPackRequest implements Built<CreateStickerPackRequest, CreateStickerPackRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  CreateStickerPackRequest._();

  factory CreateStickerPackRequest([void updates(CreateStickerPackRequestBuilder b)]) = _$CreateStickerPackRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateStickerPackRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateStickerPackRequest> get serializer => _$CreateStickerPackRequestSerializer();
}

class _$CreateStickerPackRequestSerializer implements PrimitiveSerializer<CreateStickerPackRequest> {
  @override
  final Iterable<Type> types = const [CreateStickerPackRequest, _$CreateStickerPackRequest];

  @override
  final String wireName = r'CreateStickerPackRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateStickerPackRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateStickerPackRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateStickerPackRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateStickerPackRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateStickerPackRequestBuilder();
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

