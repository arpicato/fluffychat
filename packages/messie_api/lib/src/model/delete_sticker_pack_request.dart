//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_sticker_pack_request.g.dart';

/// DeleteStickerPackRequest
///
/// Properties:
/// * [mode] 
@BuiltValue()
abstract class DeleteStickerPackRequest implements Built<DeleteStickerPackRequest, DeleteStickerPackRequestBuilder> {
  @BuiltValueField(wireName: r'mode')
  DeleteStickerPackRequestModeEnum? get mode;
  // enum modeEnum {  move_to_saved,  delete_stickers,  };

  DeleteStickerPackRequest._();

  factory DeleteStickerPackRequest([void updates(DeleteStickerPackRequestBuilder b)]) = _$DeleteStickerPackRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteStickerPackRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteStickerPackRequest> get serializer => _$DeleteStickerPackRequestSerializer();
}

class _$DeleteStickerPackRequestSerializer implements PrimitiveSerializer<DeleteStickerPackRequest> {
  @override
  final Iterable<Type> types = const [DeleteStickerPackRequest, _$DeleteStickerPackRequest];

  @override
  final String wireName = r'DeleteStickerPackRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteStickerPackRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.mode != null) {
      yield r'mode';
      yield serializers.serialize(
        object.mode,
        specifiedType: const FullType(DeleteStickerPackRequestModeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteStickerPackRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeleteStickerPackRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeleteStickerPackRequestModeEnum),
          ) as DeleteStickerPackRequestModeEnum;
          result.mode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteStickerPackRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteStickerPackRequestBuilder();
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

class DeleteStickerPackRequestModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'move_to_saved')
  static const DeleteStickerPackRequestModeEnum moveToSaved = _$deleteStickerPackRequestModeEnum_moveToSaved;
  @BuiltValueEnumConst(wireName: r'delete_stickers')
  static const DeleteStickerPackRequestModeEnum deleteStickers = _$deleteStickerPackRequestModeEnum_deleteStickers;

  static Serializer<DeleteStickerPackRequestModeEnum> get serializer => _$deleteStickerPackRequestModeEnumSerializer;

  const DeleteStickerPackRequestModeEnum._(String name): super(name);

  static BuiltSet<DeleteStickerPackRequestModeEnum> get values => _$deleteStickerPackRequestModeEnumValues;
  static DeleteStickerPackRequestModeEnum valueOf(String name) => _$deleteStickerPackRequestModeEnumValueOf(name);
}

