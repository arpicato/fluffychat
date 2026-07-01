// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_sticker_entries_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteStickerEntriesRequest extends DeleteStickerEntriesRequest {
  @override
  final String packId;
  @override
  final BuiltList<String> entryIds;

  factory _$DeleteStickerEntriesRequest(
          [void Function(DeleteStickerEntriesRequestBuilder)? updates]) =>
      (DeleteStickerEntriesRequestBuilder()..update(updates))._build();

  _$DeleteStickerEntriesRequest._(
      {required this.packId, required this.entryIds})
      : super._();
  @override
  DeleteStickerEntriesRequest rebuild(
          void Function(DeleteStickerEntriesRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteStickerEntriesRequestBuilder toBuilder() =>
      DeleteStickerEntriesRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteStickerEntriesRequest &&
        packId == other.packId &&
        entryIds == other.entryIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, packId.hashCode);
    _$hash = $jc(_$hash, entryIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteStickerEntriesRequest')
          ..add('packId', packId)
          ..add('entryIds', entryIds))
        .toString();
  }
}

class DeleteStickerEntriesRequestBuilder
    implements
        Builder<DeleteStickerEntriesRequest,
            DeleteStickerEntriesRequestBuilder> {
  _$DeleteStickerEntriesRequest? _$v;

  String? _packId;
  String? get packId => _$this._packId;
  set packId(String? packId) => _$this._packId = packId;

  ListBuilder<String>? _entryIds;
  ListBuilder<String> get entryIds =>
      _$this._entryIds ??= ListBuilder<String>();
  set entryIds(ListBuilder<String>? entryIds) => _$this._entryIds = entryIds;

  DeleteStickerEntriesRequestBuilder() {
    DeleteStickerEntriesRequest._defaults(this);
  }

  DeleteStickerEntriesRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _packId = $v.packId;
      _entryIds = $v.entryIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteStickerEntriesRequest other) {
    _$v = other as _$DeleteStickerEntriesRequest;
  }

  @override
  void update(void Function(DeleteStickerEntriesRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteStickerEntriesRequest build() => _build();

  _$DeleteStickerEntriesRequest _build() {
    _$DeleteStickerEntriesRequest _$result;
    try {
      _$result = _$v ??
          _$DeleteStickerEntriesRequest._(
            packId: BuiltValueNullFieldError.checkNotNull(
                packId, r'DeleteStickerEntriesRequest', 'packId'),
            entryIds: entryIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entryIds';
        entryIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DeleteStickerEntriesRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
