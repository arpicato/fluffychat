//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_sticker_entries_request.g.dart';

/// DeleteStickerEntriesRequest
///
/// Properties:
/// * [packId] 
/// * [entryIds] 
@BuiltValue()
abstract class DeleteStickerEntriesRequest implements Built<DeleteStickerEntriesRequest, DeleteStickerEntriesRequestBuilder> {
  @BuiltValueField(wireName: r'pack_id')
  String get packId;

  @BuiltValueField(wireName: r'entry_ids')
  BuiltList<String> get entryIds;

  DeleteStickerEntriesRequest._();

  factory DeleteStickerEntriesRequest([void updates(DeleteStickerEntriesRequestBuilder b)]) = _$DeleteStickerEntriesRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteStickerEntriesRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteStickerEntriesRequest> get serializer => _$DeleteStickerEntriesRequestSerializer();
}

class _$DeleteStickerEntriesRequestSerializer implements PrimitiveSerializer<DeleteStickerEntriesRequest> {
  @override
  final Iterable<Type> types = const [DeleteStickerEntriesRequest, _$DeleteStickerEntriesRequest];

  @override
  final String wireName = r'DeleteStickerEntriesRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteStickerEntriesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pack_id';
    yield serializers.serialize(
      object.packId,
      specifiedType: const FullType(String),
    );
    yield r'entry_ids';
    yield serializers.serialize(
      object.entryIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteStickerEntriesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeleteStickerEntriesRequestBuilder result,
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
        case r'entry_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.entryIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteStickerEntriesRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteStickerEntriesRequestBuilder();
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

