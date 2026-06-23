// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_sticker_pack_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateStickerPackRequest extends CreateStickerPackRequest {
  @override
  final String name;

  factory _$CreateStickerPackRequest(
          [void Function(CreateStickerPackRequestBuilder)? updates]) =>
      (CreateStickerPackRequestBuilder()..update(updates))._build();

  _$CreateStickerPackRequest._({required this.name}) : super._();
  @override
  CreateStickerPackRequest rebuild(
          void Function(CreateStickerPackRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateStickerPackRequestBuilder toBuilder() =>
      CreateStickerPackRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateStickerPackRequest && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateStickerPackRequest')
          ..add('name', name))
        .toString();
  }
}

class CreateStickerPackRequestBuilder
    implements
        Builder<CreateStickerPackRequest, CreateStickerPackRequestBuilder> {
  _$CreateStickerPackRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CreateStickerPackRequestBuilder() {
    CreateStickerPackRequest._defaults(this);
  }

  CreateStickerPackRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateStickerPackRequest other) {
    _$v = other as _$CreateStickerPackRequest;
  }

  @override
  void update(void Function(CreateStickerPackRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateStickerPackRequest build() => _build();

  _$CreateStickerPackRequest _build() {
    final _$result = _$v ??
        _$CreateStickerPackRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CreateStickerPackRequest', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
