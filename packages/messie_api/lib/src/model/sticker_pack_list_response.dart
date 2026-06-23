//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:messie_api/src/model/sticker_pack.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sticker_pack_list_response.g.dart';

/// StickerPackListResponse
///
/// Properties:
/// * [packs] 
@BuiltValue()
abstract class StickerPackListResponse implements Built<StickerPackListResponse, StickerPackListResponseBuilder> {
  @BuiltValueField(wireName: r'packs')
  BuiltList<StickerPack> get packs;

  StickerPackListResponse._();

  factory StickerPackListResponse([void updates(StickerPackListResponseBuilder b)]) = _$StickerPackListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickerPackListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickerPackListResponse> get serializer => _$StickerPackListResponseSerializer();
}

class _$StickerPackListResponseSerializer implements PrimitiveSerializer<StickerPackListResponse> {
  @override
  final Iterable<Type> types = const [StickerPackListResponse, _$StickerPackListResponse];

  @override
  final String wireName = r'StickerPackListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickerPackListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'packs';
    yield serializers.serialize(
      object.packs,
      specifiedType: const FullType(BuiltList, [FullType(StickerPack)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StickerPackListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickerPackListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'packs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StickerPack)]),
          ) as BuiltList<StickerPack>;
          result.packs.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StickerPackListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickerPackListResponseBuilder();
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

