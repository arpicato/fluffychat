//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_sticker_entry_request.g.dart';

/// DeleteStickerEntryRequest
///
/// Properties:
/// * [packId] 
@BuiltValue()
abstract class DeleteStickerEntryRequest implements Built<DeleteStickerEntryRequest, DeleteStickerEntryRequestBuilder> {
  @BuiltValueField(wireName: r'pack_id')
  String? get packId;

  DeleteStickerEntryRequest._();

  factory DeleteStickerEntryRequest([void updates(DeleteStickerEntryRequestBuilder b)]) = _$DeleteStickerEntryRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteStickerEntryRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteStickerEntryRequest> get serializer => _$DeleteStickerEntryRequestSerializer();
}

class _$DeleteStickerEntryRequestSerializer implements PrimitiveSerializer<DeleteStickerEntryRequest> {
  @override
  final Iterable<Type> types = const [DeleteStickerEntryRequest, _$DeleteStickerEntryRequest];

  @override
  final String wireName = r'DeleteStickerEntryRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteStickerEntryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.packId != null) {
      yield r'pack_id';
      yield serializers.serialize(
        object.packId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteStickerEntryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeleteStickerEntryRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pack_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.packId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteStickerEntryRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteStickerEntryRequestBuilder();
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

