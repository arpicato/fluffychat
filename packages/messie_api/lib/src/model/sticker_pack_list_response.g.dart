// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_pack_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StickerPackListResponse extends StickerPackListResponse {
  @override
  final BuiltList<StickerPack> packs;

  factory _$StickerPackListResponse(
          [void Function(StickerPackListResponseBuilder)? updates]) =>
      (StickerPackListResponseBuilder()..update(updates))._build();

  _$StickerPackListResponse._({required this.packs}) : super._();
  @override
  StickerPackListResponse rebuild(
          void Function(StickerPackListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StickerPackListResponseBuilder toBuilder() =>
      StickerPackListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickerPackListResponse && packs == other.packs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, packs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StickerPackListResponse')
          ..add('packs', packs))
        .toString();
  }
}

class StickerPackListResponseBuilder
    implements
        Builder<StickerPackListResponse, StickerPackListResponseBuilder> {
  _$StickerPackListResponse? _$v;

  ListBuilder<StickerPack>? _packs;
  ListBuilder<StickerPack> get packs =>
      _$this._packs ??= ListBuilder<StickerPack>();
  set packs(ListBuilder<StickerPack>? packs) => _$this._packs = packs;

  StickerPackListResponseBuilder() {
    StickerPackListResponse._defaults(this);
  }

  StickerPackListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _packs = $v.packs.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StickerPackListResponse other) {
    _$v = other as _$StickerPackListResponse;
  }

  @override
  void update(void Function(StickerPackListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickerPackListResponse build() => _build();

  _$StickerPackListResponse _build() {
    _$StickerPackListResponse _$result;
    try {
      _$result = _$v ??
          _$StickerPackListResponse._(
            packs: packs.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'packs';
        packs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StickerPackListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
