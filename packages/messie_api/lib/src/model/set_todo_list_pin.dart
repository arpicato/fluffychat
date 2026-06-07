//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'set_todo_list_pin.g.dart';

/// SetTodoListPin
///
/// Properties:
/// * [pinned] 
@BuiltValue()
abstract class SetTodoListPin implements Built<SetTodoListPin, SetTodoListPinBuilder> {
  @BuiltValueField(wireName: r'pinned')
  bool get pinned;

  SetTodoListPin._();

  factory SetTodoListPin([void updates(SetTodoListPinBuilder b)]) = _$SetTodoListPin;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SetTodoListPinBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SetTodoListPin> get serializer => _$SetTodoListPinSerializer();
}

class _$SetTodoListPinSerializer implements PrimitiveSerializer<SetTodoListPin> {
  @override
  final Iterable<Type> types = const [SetTodoListPin, _$SetTodoListPin];

  @override
  final String wireName = r'SetTodoListPin';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SetTodoListPin object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pinned';
    yield serializers.serialize(
      object.pinned,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SetTodoListPin object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SetTodoListPinBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pinned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pinned = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SetTodoListPin deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SetTodoListPinBuilder();
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

