//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'new_calendar_event.g.dart';

/// NewCalendarEvent
///
/// Properties:
/// * [sourceId] 
/// * [title] 
/// * [description] 
/// * [location] 
/// * [startTime] 
/// * [endTime] 
/// * [allDay] 
@BuiltValue()
abstract class NewCalendarEvent implements Built<NewCalendarEvent, NewCalendarEventBuilder> {
  @BuiltValueField(wireName: r'source_id')
  String get sourceId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'location')
  String? get location;

  @BuiltValueField(wireName: r'start_time')
  DateTime get startTime;

  @BuiltValueField(wireName: r'end_time')
  DateTime get endTime;

  @BuiltValueField(wireName: r'all_day')
  bool? get allDay;

  NewCalendarEvent._();

  factory NewCalendarEvent([void updates(NewCalendarEventBuilder b)]) = _$NewCalendarEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NewCalendarEventBuilder b) => b
      ..description = ''
      ..location = ''
      ..allDay = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<NewCalendarEvent> get serializer => _$NewCalendarEventSerializer();
}

class _$NewCalendarEventSerializer implements PrimitiveSerializer<NewCalendarEvent> {
  @override
  final Iterable<Type> types = const [NewCalendarEvent, _$NewCalendarEvent];

  @override
  final String wireName = r'NewCalendarEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NewCalendarEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'source_id';
    yield serializers.serialize(
      object.sourceId,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.location != null) {
      yield r'location';
      yield serializers.serialize(
        object.location,
        specifiedType: const FullType(String),
      );
    }
    yield r'start_time';
    yield serializers.serialize(
      object.startTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'end_time';
    yield serializers.serialize(
      object.endTime,
      specifiedType: const FullType(DateTime),
    );
    if (object.allDay != null) {
      yield r'all_day';
      yield serializers.serialize(
        object.allDay,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NewCalendarEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NewCalendarEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'source_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.location = valueDes;
          break;
        case r'start_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startTime = valueDes;
          break;
        case r'end_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endTime = valueDes;
          break;
        case r'all_day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.allDay = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NewCalendarEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NewCalendarEventBuilder();
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

