//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'save_sticker_entry_request.g.dart';

/// SaveStickerEntryRequest
///
/// Properties:
/// * [packId] 
/// * [contentHash] 
/// * [body] 
/// * [encryptedFile] 
/// * [info] 
/// * [thumbnailEncryptedFile] 
/// * [thumbnailInfo] 
/// * [animated] 
/// * [sizeBytes] 
/// * [mxcUri] 
/// * [mediaId] 
@BuiltValue()
abstract class SaveStickerEntryRequest implements Built<SaveStickerEntryRequest, SaveStickerEntryRequestBuilder> {
  @BuiltValueField(wireName: r'pack_id')
  String get packId;

  @BuiltValueField(wireName: r'content_hash')
  String get contentHash;

  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'encrypted_file')
  BuiltMap<String, JsonObject?> get encryptedFile;

  @BuiltValueField(wireName: r'info')
  BuiltMap<String, JsonObject?>? get info;

  @BuiltValueField(wireName: r'thumbnail_encrypted_file')
  BuiltMap<String, JsonObject?>? get thumbnailEncryptedFile;

  @BuiltValueField(wireName: r'thumbnail_info')
  BuiltMap<String, JsonObject?>? get thumbnailInfo;

  @BuiltValueField(wireName: r'animated')
  bool? get animated;

  @BuiltValueField(wireName: r'size_bytes')
  int get sizeBytes;

  @BuiltValueField(wireName: r'mxc_uri')
  String get mxcUri;

  @BuiltValueField(wireName: r'media_id')
  String get mediaId;

  SaveStickerEntryRequest._();

  factory SaveStickerEntryRequest([void updates(SaveStickerEntryRequestBuilder b)]) = _$SaveStickerEntryRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SaveStickerEntryRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SaveStickerEntryRequest> get serializer => _$SaveStickerEntryRequestSerializer();
}

class _$SaveStickerEntryRequestSerializer implements PrimitiveSerializer<SaveStickerEntryRequest> {
  @override
  final Iterable<Type> types = const [SaveStickerEntryRequest, _$SaveStickerEntryRequest];

  @override
  final String wireName = r'SaveStickerEntryRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SaveStickerEntryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pack_id';
    yield serializers.serialize(
      object.packId,
      specifiedType: const FullType(String),
    );
    yield r'content_hash';
    yield serializers.serialize(
      object.contentHash,
      specifiedType: const FullType(String),
    );
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    yield r'encrypted_file';
    yield serializers.serialize(
      object.encryptedFile,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    if (object.info != null) {
      yield r'info';
      yield serializers.serialize(
        object.info,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.thumbnailEncryptedFile != null) {
      yield r'thumbnail_encrypted_file';
      yield serializers.serialize(
        object.thumbnailEncryptedFile,
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
    yield r'size_bytes';
    yield serializers.serialize(
      object.sizeBytes,
      specifiedType: const FullType(int),
    );
    yield r'mxc_uri';
    yield serializers.serialize(
      object.mxcUri,
      specifiedType: const FullType(String),
    );
    yield r'media_id';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SaveStickerEntryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SaveStickerEntryRequestBuilder result,
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
        case r'content_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentHash = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'encrypted_file':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.encryptedFile.replace(valueDes);
          break;
        case r'info':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.info.replace(valueDes);
          break;
        case r'thumbnail_encrypted_file':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.thumbnailEncryptedFile.replace(valueDes);
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
        case r'size_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sizeBytes = valueDes;
          break;
        case r'mxc_uri':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mxcUri = valueDes;
          break;
        case r'media_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SaveStickerEntryRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SaveStickerEntryRequestBuilder();
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

