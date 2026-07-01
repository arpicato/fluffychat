// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_sticker_entry_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteStickerEntryRequest extends DeleteStickerEntryRequest {
  @override
  final String? packId;

  factory _$DeleteStickerEntryRequest(
          [void Function(DeleteStickerEntryRequestBuilder)? updates]) =>
      (DeleteStickerEntryRequestBuilder()..update(updates))._build();

  _$DeleteStickerEntryRequest._({this.packId}) : super._();
  @override
  DeleteStickerEntryRequest rebuild(
          void Function(DeleteStickerEntryRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteStickerEntryRequestBuilder toBuilder() =>
      DeleteStickerEntryRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteStickerEntryRequest && packId == other.packId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, packId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteStickerEntryRequest')
          ..add('packId', packId))
        .toString();
  }
}

class DeleteStickerEntryRequestBuilder
    implements
        Builder<DeleteStickerEntryRequest, DeleteStickerEntryRequestBuilder> {
  _$DeleteStickerEntryRequest? _$v;

  String? _packId;
  String? get packId => _$this._packId;
  set packId(String? packId) => _$this._packId = packId;

  DeleteStickerEntryRequestBuilder() {
    DeleteStickerEntryRequest._defaults(this);
  }

  DeleteStickerEntryRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _packId = $v.packId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteStickerEntryRequest other) {
    _$v = other as _$DeleteStickerEntryRequest;
  }

  @override
  void update(void Function(DeleteStickerEntryRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteStickerEntryRequest build() => _build();

  _$DeleteStickerEntryRequest _build() {
    final _$result = _$v ??
        _$DeleteStickerEntryRequest._(
          packId: packId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
