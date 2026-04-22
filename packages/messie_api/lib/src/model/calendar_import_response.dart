//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:messie_api/src/model/calendar_source.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'calendar_import_response.g.dart';

/// CalendarImportResponse
///
/// Properties:
/// * [source_] 
/// * [importedEventCount] 
@BuiltValue()
abstract class CalendarImportResponse implements Built<CalendarImportResponse, CalendarImportResponseBuilder> {
  @BuiltValueField(wireName: r'source')
  CalendarSource get source_;

  @BuiltValueField(wireName: r'imported_event_count')
  int get importedEventCount;

  CalendarImportResponse._();

  factory CalendarImportResponse([void updates(CalendarImportResponseBuilder b)]) = _$CalendarImportResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CalendarImportResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CalendarImportResponse> get serializer => _$CalendarImportResponseSerializer();
}

class _$CalendarImportResponseSerializer implements PrimitiveSerializer<CalendarImportResponse> {
  @override
  final Iterable<Type> types = const [CalendarImportResponse, _$CalendarImportResponse];

  @override
  final String wireName = r'CalendarImportResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CalendarImportResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(CalendarSource),
    );
    yield r'imported_event_count';
    yield serializers.serialize(
      object.importedEventCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CalendarImportResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CalendarImportResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CalendarSource),
          ) as CalendarSource;
          result.source_.replace(valueDes);
          break;
        case r'imported_event_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.importedEventCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CalendarImportResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CalendarImportResponseBuilder();
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

