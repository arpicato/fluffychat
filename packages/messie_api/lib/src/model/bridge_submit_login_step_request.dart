//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'bridge_submit_login_step_request.g.dart';

/// BridgeSubmitLoginStepRequest
@BuiltValue()
abstract class BridgeSubmitLoginStepRequest implements Built<BridgeSubmitLoginStepRequest, BridgeSubmitLoginStepRequestBuilder> {
  /// One Of [BuiltMap<String, JsonObject>], [BuiltMap<String, String>], [JsonObject]
  OneOf get oneOf;

  BridgeSubmitLoginStepRequest._();

  factory BridgeSubmitLoginStepRequest([void updates(BridgeSubmitLoginStepRequestBuilder b)]) = _$BridgeSubmitLoginStepRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BridgeSubmitLoginStepRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BridgeSubmitLoginStepRequest> get serializer => _$BridgeSubmitLoginStepRequestSerializer();
}

class _$BridgeSubmitLoginStepRequestSerializer implements PrimitiveSerializer<BridgeSubmitLoginStepRequest> {
  @override
  final Iterable<Type> types = const [BridgeSubmitLoginStepRequest, _$BridgeSubmitLoginStepRequest];

  @override
  final String wireName = r'BridgeSubmitLoginStepRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BridgeSubmitLoginStepRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    BridgeSubmitLoginStepRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  BridgeSubmitLoginStepRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BridgeSubmitLoginStepRequestBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [FullType(JsonObject), FullType(BuiltMap, [FullType(String), FullType(String)]), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
    return result.build();
  }
}

