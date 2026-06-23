//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sticker_entry.g.dart';

/// StickerEntry
///
/// Properties:
/// * [id] 
/// * [code] 
/// * [body] 
/// * [contentHash] 
/// * [createdAt] 
/// * [file] 
/// * [info] 
/// * [thumbnailFile] 
/// * [thumbnailInfo] 
/// * [animated] 
/// * [packIds] 
@BuiltValue()
abstract class StickerEntry implements Built<StickerEntry, StickerEntryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'content_hash')
  String get contentHash;

  @BuiltValueField(wireName: r'created_at')
  int get createdAt;

  @BuiltValueField(wireName: r'file')
  BuiltMap<String, JsonObject?> get file;

  @BuiltValueField(wireName: r'info')
  BuiltMap<String, JsonObject?> get info;

  @BuiltValueField(wireName: r'thumbnail_file')
  BuiltMap<String, JsonObject?>? get thumbnailFile;

  @BuiltValueField(wireName: r'thumbnail_info')
  BuiltMap<String, JsonObject?>? get thumbnailInfo;

  @BuiltValueField(wireName: r'animated')
  bool? get animated;

  @BuiltValueField(wireName: r'pack_ids')
  BuiltList<String> get packIds;

  StickerEntry._();

  factory StickerEntry([void updates(StickerEntryBuilder b)]) = _$StickerEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickerEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickerEntry> get serializer => _$StickerEntrySerializer();
}

class _$StickerEntrySerializer implements PrimitiveSerializer<StickerEntry> {
  @override
  final Iterable<Type> types = const [StickerEntry, _$StickerEntry];

  @override
  final String wireName = r'StickerEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickerEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    yield r'content_hash';
    yield serializers.serialize(
      object.contentHash,
      specifiedType: const FullType(String),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(int),
    );
    yield r'file';
    yield serializers.serialize(
      object.file,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'info';
    yield serializers.serialize(
      object.info,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    if (object.thumbnailFile != null) {
      yield r'thumbnail_file';
      yield serializers.serialize(
        object.thumbnailFile,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.thumbnailInfo != null) {
      yield r'thumbnail_info';
      yield serializers.serialize(
        object.thumbnailInfo,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.animated != null) {
      yield r'animated';
      yield serializers.serialize(
        object.animated,
        specifiedType: const FullType(bool),
      );
    }
    yield r'pack_ids';
    yield serializers.serialize(
      object.packIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StickerEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickerEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'content_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentHash = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.createdAt = valueDes;
          break;
        case r'file':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.file.replace(valueDes);
          break;
        case r'info':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.info.replace(valueDes);
          break;
        case r'thumbnail_file':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.thumbnailFile.replace(valueDes);
          break;
        case r'thumbnail_info':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.thumbnailInfo.replace(valueDes);
          break;
        case r'animated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.animated = valueDes;
          break;
        case r'pack_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.packIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StickerEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickerEntryBuilder();
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

