// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_step_complete.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LoginStepCompleteTypeEnum _$loginStepCompleteTypeEnum_complete =
    const LoginStepCompleteTypeEnum._('complete');

LoginStepCompleteTypeEnum _$loginStepCompleteTypeEnumValueOf(String name) {
  switch (name) {
    case 'complete':
      return _$loginStepCompleteTypeEnum_complete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LoginStepCompleteTypeEnum> _$loginStepCompleteTypeEnumValues =
    BuiltSet<LoginStepCompleteTypeEnum>(const <LoginStepCompleteTypeEnum>[
  _$loginStepCompleteTypeEnum_complete,
]);

Serializer<LoginStepCompleteTypeEnum> _$loginStepCompleteTypeEnumSerializer =
    _$LoginStepCompleteTypeEnumSerializer();

class _$LoginStepCompleteTypeEnumSerializer
    implements PrimitiveSerializer<LoginStepCompleteTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'complete': 'complete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'complete': 'complete',
  };

  @override
  final Iterable<Type> types = const <Type>[LoginStepCompleteTypeEnum];
  @override
  final String wireName = 'LoginStepCompleteTypeEnum';

  @override
  Object serialize(Serializers serializers, LoginStepCompleteTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LoginStepCompleteTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LoginStepCompleteTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LoginStepComplete extends LoginStepComplete {
  @override
  final LoginStepCompleteTypeEnum type;
  @override
  final String? processId;
  @override
  final String? loginId;
  @override
  final String? stepId;
  @override
  final LoginStepCompleteComplete complete;

  factory _$LoginStepComplete(
          [void Function(LoginStepCompleteBuilder)? updates]) =>
      (LoginStepCompleteBuilder()..update(updates))._build();

  _$LoginStepComplete._(
      {required this.type,
      this.processId,
      this.loginId,
      this.stepId,
      required this.complete})
      : super._();
  @override
  LoginStepComplete rebuild(void Function(LoginStepCompleteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoginStepCompleteBuilder toBuilder() =>
      LoginStepCompleteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoginStepComplete &&
        type == other.type &&
        processId == other.processId &&
        loginId == other.loginId &&
        stepId == other.stepId &&
        complete == other.complete;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, processId.hashCode);
    _$hash = $jc(_$hash, loginId.hashCode);
    _$hash = $jc(_$hash, stepId.hashCode);
    _$hash = $jc(_$hash, complete.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LoginStepComplete')
          ..add('type', type)
          ..add('processId', processId)
          ..add('loginId', loginId)
          ..add('stepId', stepId)
          ..add('complete', complete))
        .toString();
  }
}

class LoginStepCompleteBuilder
    implements Builder<LoginStepComplete, LoginStepCompleteBuilder> {
  _$LoginStepComplete? _$v;

  LoginStepCompleteTypeEnum? _type;
  LoginStepCompleteTypeEnum? get type => _$this._type;
  set type(LoginStepCompleteTypeEnum? type) => _$this._type = type;

  String? _processId;
  String? get processId => _$this._processId;
  set processId(String? processId) => _$this._processId = processId;

  String? _loginId;
  String? get loginId => _$this._loginId;
  set loginId(String? loginId) => _$this._loginId = loginId;

  String? _stepId;
  String? get stepId => _$this._stepId;
  set stepId(String? stepId) => _$this._stepId = stepId;

  LoginStepCompleteCompleteBuilder? _complete;
  LoginStepCompleteCompleteBuilder get complete =>
      _$this._complete ??= LoginStepCompleteCompleteBuilder();
  set complete(LoginStepCompleteCompleteBuilder? complete) =>
      _$this._complete = complete;

  LoginStepCompleteBuilder() {
    LoginStepComplete._defaults(this);
  }

  LoginStepCompleteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _processId = $v.processId;
      _loginId = $v.loginId;
      _stepId = $v.stepId;
      _complete = $v.complete.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LoginStepComplete other) {
    _$v = other as _$LoginStepComplete;
  }

  @override
  void update(void Function(LoginStepCompleteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LoginStepComplete build() => _build();

  _$LoginStepComplete _build() {
    _$LoginStepComplete _$result;
    try {
      _$result = _$v ??
          _$LoginStepComplete._(
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'LoginStepComplete', 'type'),
            processId: processId,
            loginId: loginId,
            stepId: stepId,
            complete: complete.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'complete';
        complete.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LoginStepComplete', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
