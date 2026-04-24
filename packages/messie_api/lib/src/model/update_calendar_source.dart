//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_calendar_source.g.dart';

/// UpdateCalendarSource
///
/// Properties:
/// * [category] 
/// * [displayName] 
@BuiltValue()
abstract class UpdateCalendarSource implements Built<UpdateCalendarSource, UpdateCalendarSourceBuilder> {
  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  UpdateCalendarSource._();

  factory UpdateCalendarSource([void updates(UpdateCalendarSourceBuilder b)]) = _$UpdateCalendarSource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateCalendarSourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateCalendarSource> get serializer => _$UpdateCalendarSourceSerializer();
}

class _$UpdateCalendarSourceSerializer implements PrimitiveSerializer<UpdateCalendarSource> {
  @override
  final Iterable<Type> types = const [UpdateCalendarSource, _$UpdateCalendarSource];

  @override
  final String wireName = r'UpdateCalendarSource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateCalendarSource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(String),
    );
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateCalendarSource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateCalendarSourceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateCalendarSource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateCalendarSourceBuilder();
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
