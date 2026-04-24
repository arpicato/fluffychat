//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'calendar_source.g.dart';

/// CalendarSource
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [kind] 
/// * [displayName] 
/// * [category] 
/// * [importMode] 
/// * [sourceUrl] 
/// * [refreshState] 
/// * [lastSyncedAt] 
/// * [lastRefreshAttemptAt] 
/// * [lastRefreshError] 
/// * [etag] 
/// * [lastModified] 
/// * [nextRefreshAt] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class CalendarSource implements Built<CalendarSource, CalendarSourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'kind')
  String get kind;

  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'import_mode')
  String get importMode;

  @BuiltValueField(wireName: r'source_url')
  String? get sourceUrl;

  @BuiltValueField(wireName: r'refresh_state')
  String get refreshState;

  @BuiltValueField(wireName: r'last_synced_at')
  DateTime? get lastSyncedAt;

  @BuiltValueField(wireName: r'last_refresh_attempt_at')
  DateTime? get lastRefreshAttemptAt;

  @BuiltValueField(wireName: r'last_refresh_error')
  String? get lastRefreshError;

  @BuiltValueField(wireName: r'etag')
  String? get etag;

  @BuiltValueField(wireName: r'last_modified')
  DateTime? get lastModified;

  @BuiltValueField(wireName: r'next_refresh_at')
  DateTime? get nextRefreshAt;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  CalendarSource._();

  factory CalendarSource([void updates(CalendarSourceBuilder b)]) = _$CalendarSource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CalendarSourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CalendarSource> get serializer => _$CalendarSourceSerializer();
}

class _$CalendarSourceSerializer implements PrimitiveSerializer<CalendarSource> {
  @override
  final Iterable<Type> types = const [CalendarSource, _$CalendarSource];

  @override
  final String wireName = r'CalendarSource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CalendarSource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(String),
    );
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(String),
    );
    yield r'import_mode';
    yield serializers.serialize(
      object.importMode,
      specifiedType: const FullType(String),
    );
    if (object.sourceUrl != null) {
      yield r'source_url';
      yield serializers.serialize(
        object.sourceUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'refresh_state';
    yield serializers.serialize(
      object.refreshState,
      specifiedType: const FullType(String),
    );
    if (object.lastSyncedAt != null) {
      yield r'last_synced_at';
      yield serializers.serialize(
        object.lastSyncedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.lastRefreshAttemptAt != null) {
      yield r'last_refresh_attempt_at';
      yield serializers.serialize(
        object.lastRefreshAttemptAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.lastRefreshError != null) {
      yield r'last_refresh_error';
      yield serializers.serialize(
        object.lastRefreshError,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.etag != null) {
      yield r'etag';
      yield serializers.serialize(
        object.etag,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lastModified != null) {
      yield r'last_modified';
      yield serializers.serialize(
        object.lastModified,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.nextRefreshAt != null) {
      yield r'next_refresh_at';
      yield serializers.serialize(
        object.nextRefreshAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CalendarSource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CalendarSourceBuilder result,
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
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kind = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
          break;
        case r'import_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.importMode = valueDes;
          break;
        case r'source_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceUrl = valueDes;
          break;
        case r'refresh_state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshState = valueDes;
          break;
        case r'last_synced_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastSyncedAt = valueDes;
          break;
        case r'last_refresh_attempt_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastRefreshAttemptAt = valueDes;
          break;
        case r'last_refresh_error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastRefreshError = valueDes;
          break;
        case r'etag':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.etag = valueDes;
          break;
        case r'last_modified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastModified = valueDes;
          break;
        case r'next_refresh_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.nextRefreshAt = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CalendarSource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CalendarSourceBuilder();
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
