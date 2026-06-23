//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'move_sticker_entry_request.g.dart';

/// MoveStickerEntryRequest
///
/// Properties:
/// * [packId] 
@BuiltValue()
abstract class MoveStickerEntryRequest implements Built<MoveStickerEntryRequest, MoveStickerEntryRequestBuilder> {
  @BuiltValueField(wireName: r'pack_id')
  String get packId;

  MoveStickerEntryRequest._();

  factory MoveStickerEntryRequest([void updates(MoveStickerEntryRequestBuilder b)]) = _$MoveStickerEntryRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MoveStickerEntryRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MoveStickerEntryRequest> get serializer => _$MoveStickerEntryRequestSerializer();
}

class _$MoveStickerEntryRequestSerializer implements PrimitiveSerializer<MoveStickerEntryRequest> {
  @override
  final Iterable<Type> types = const [MoveStickerEntryRequest, _$MoveStickerEntryRequest];

  @override
  final String wireName = r'MoveStickerEntryRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MoveStickerEntryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pack_id';
    yield serializers.serialize(
      object.packId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MoveStickerEntryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MoveStickerEntryRequestBuilder result,
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
  MoveStickerEntryRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MoveStickerEntryRequestBuilder();
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

