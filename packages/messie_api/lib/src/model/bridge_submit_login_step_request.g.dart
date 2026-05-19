// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_submit_login_step_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BridgeSubmitLoginStepRequest extends BridgeSubmitLoginStepRequest {
  @override
  final OneOf oneOf;

  factory _$BridgeSubmitLoginStepRequest(
          [void Function(BridgeSubmitLoginStepRequestBuilder)? updates]) =>
      (BridgeSubmitLoginStepRequestBuilder()..update(updates))._build();

  _$BridgeSubmitLoginStepRequest._({required this.oneOf}) : super._();
  @override
  BridgeSubmitLoginStepRequest rebuild(
          void Function(BridgeSubmitLoginStepRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BridgeSubmitLoginStepRequestBuilder toBuilder() =>
      BridgeSubmitLoginStepRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BridgeSubmitLoginStepRequest && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BridgeSubmitLoginStepRequest')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class BridgeSubmitLoginStepRequestBuilder
    implements
        Builder<BridgeSubmitLoginStepRequest,
            BridgeSubmitLoginStepRequestBuilder> {
  _$BridgeSubmitLoginStepRequest? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  BridgeSubmitLoginStepRequestBuilder() {
    BridgeSubmitLoginStepRequest._defaults(this);
  }

  BridgeSubmitLoginStepRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BridgeSubmitLoginStepRequest other) {
    _$v = other as _$BridgeSubmitLoginStepRequest;
  }

  @override
  void update(void Function(BridgeSubmitLoginStepRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BridgeSubmitLoginStepRequest build() => _build();

  _$BridgeSubmitLoginStepRequest _build() {
    final _$result = _$v ??
        _$BridgeSubmitLoginStepRequest._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'BridgeSubmitLoginStepRequest', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
