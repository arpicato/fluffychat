// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_sticker_entry_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MoveStickerEntryRequest extends MoveStickerEntryRequest {
  @override
  final String packId;

  factory _$MoveStickerEntryRequest(
          [void Function(MoveStickerEntryRequestBuilder)? updates]) =>
      (MoveStickerEntryRequestBuilder()..update(updates))._build();

  _$MoveStickerEntryRequest._({required this.packId}) : super._();
  @override
  MoveStickerEntryRequest rebuild(
          void Function(MoveStickerEntryRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MoveStickerEntryRequestBuilder toBuilder() =>
      MoveStickerEntryRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MoveStickerEntryRequest && packId == other.packId;
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
    return (newBuiltValueToStringHelper(r'MoveStickerEntryRequest')
          ..add('packId', packId))
        .toString();
  }
}

class MoveStickerEntryRequestBuilder
    implements
        Builder<MoveStickerEntryRequest, MoveStickerEntryRequestBuilder> {
  _$MoveStickerEntryRequest? _$v;

  String? _packId;
  String? get packId => _$this._packId;
  set packId(String? packId) => _$this._packId = packId;

  MoveStickerEntryRequestBuilder() {
    MoveStickerEntryRequest._defaults(this);
  }

  MoveStickerEntryRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _packId = $v.packId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MoveStickerEntryRequest other) {
    _$v = other as _$MoveStickerEntryRequest;
  }

  @override
  void update(void Function(MoveStickerEntryRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MoveStickerEntryRequest build() => _build();

  _$MoveStickerEntryRequest _build() {
    final _$result = _$v ??
        _$MoveStickerEntryRequest._(
          packId: BuiltValueNullFieldError.checkNotNull(
              packId, r'MoveStickerEntryRequest', 'packId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
