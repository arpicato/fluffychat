//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'new_calendar_link_source.g.dart';

/// NewCalendarLinkSource
///
/// Properties:
/// * [url] 
/// * [displayName] 
@BuiltValue()
abstract class NewCalendarLinkSource implements Built<NewCalendarLinkSource, NewCalendarLinkSourceBuilder> {
  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  NewCalendarLinkSource._();

  factory NewCalendarLinkSource([void updates(NewCalendarLinkSourceBuilder b)]) = _$NewCalendarLinkSource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NewCalendarLinkSourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NewCalendarLinkSource> get serializer => _$NewCalendarLinkSourceSerializer();
}

class _$NewCalendarLinkSourceSerializer implements PrimitiveSerializer<NewCalendarLinkSource> {
  @override
  final Iterable<Type> types = const [NewCalendarLinkSource, _$NewCalendarLinkSource];

  @override
  final String wireName = r'NewCalendarLinkSource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NewCalendarLinkSource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    if (object.displayName != null) {
      yield r'display_name';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NewCalendarLinkSource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NewCalendarLinkSourceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
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
  NewCalendarLinkSource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NewCalendarLinkSourceBuilder();
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

