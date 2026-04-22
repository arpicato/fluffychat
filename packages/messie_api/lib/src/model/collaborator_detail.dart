//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'collaborator_detail.g.dart';

/// CollaboratorDetail
///
/// Properties:
/// * [listId] - ID of the todo list
/// * [username] - Collaborator username
/// * [collaboratorId] - ID of the collaborator user
/// * [matrixId] - Matrix ID of the collaborator
/// * [displayName] - Human-friendly collaborator name when available
@BuiltValue()
abstract class CollaboratorDetail implements Built<CollaboratorDetail, CollaboratorDetailBuilder> {
  /// ID of the todo list
  @BuiltValueField(wireName: r'list_id')
  String get listId;

  /// Collaborator username
  @BuiltValueField(wireName: r'username')
  String get username;

  /// ID of the collaborator user
  @BuiltValueField(wireName: r'collaborator_id')
  String get collaboratorId;

  /// Matrix ID of the collaborator
  @BuiltValueField(wireName: r'matrix_id')
  String get matrixId;

  /// Human-friendly collaborator name when available
  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  CollaboratorDetail._();

  factory CollaboratorDetail([void updates(CollaboratorDetailBuilder b)]) = _$CollaboratorDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CollaboratorDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CollaboratorDetail> get serializer => _$CollaboratorDetailSerializer();
}

class _$CollaboratorDetailSerializer implements PrimitiveSerializer<CollaboratorDetail> {
  @override
  final Iterable<Type> types = const [CollaboratorDetail, _$CollaboratorDetail];

  @override
  final String wireName = r'CollaboratorDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CollaboratorDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'list_id';
    yield serializers.serialize(
      object.listId,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'collaborator_id';
    yield serializers.serialize(
      object.collaboratorId,
      specifiedType: const FullType(String),
    );
    yield r'matrix_id';
    yield serializers.serialize(
      object.matrixId,
      specifiedType: const FullType(String),
    );
    if (object.displayName != null) {
      yield r'display_name';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CollaboratorDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CollaboratorDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'list_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.listId = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'collaborator_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.collaboratorId = valueDes;
          break;
        case r'matrix_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.matrixId = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  CollaboratorDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CollaboratorDetailBuilder();
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

