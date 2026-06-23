//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:messie_api/src/model/sticker_entry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sticker_entry_list_response.g.dart';

/// StickerEntryListResponse
///
/// Properties:
/// * [entries] 
@BuiltValue()
abstract class StickerEntryListResponse implements Built<StickerEntryListResponse, StickerEntryListResponseBuilder> {
  @BuiltValueField(wireName: r'entries')
  BuiltList<StickerEntry> get entries;

  StickerEntryListResponse._();

  factory StickerEntryListResponse([void updates(StickerEntryListResponseBuilder b)]) = _$StickerEntryListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickerEntryListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickerEntryListResponse> get serializer => _$StickerEntryListResponseSerializer();
}

class _$StickerEntryListResponseSerializer implements PrimitiveSerializer<StickerEntryListResponse> {
  @override
  final Iterable<Type> types = const [StickerEntryListResponse, _$StickerEntryListResponse];

  @override
  final String wireName = r'StickerEntryListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickerEntryListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'entries';
    yield serializers.serialize(
      object.entries,
      specifiedType: const FullType(BuiltList, [FullType(StickerEntry)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StickerEntryListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickerEntryListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StickerEntry)]),
          ) as BuiltList<StickerEntry>;
          result.entries.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StickerEntryListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickerEntryListResponseBuilder();
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

