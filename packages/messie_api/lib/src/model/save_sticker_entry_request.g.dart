// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_sticker_entry_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SaveStickerEntryRequest extends SaveStickerEntryRequest {
  @override
  final String packId;
  @override
  final String contentHash;
  @override
  final String body;
  @override
  final BuiltMap<String, JsonObject?> encryptedFile;
  @override
  final BuiltMap<String, JsonObject?>? info;
  @override
  final BuiltMap<String, JsonObject?>? thumbnailEncryptedFile;
  @override
  final BuiltMap<String, JsonObject?>? thumbnailInfo;
  @override
  final bool? animated;
  @override
  final int sizeBytes;
  @override
  final String mxcUri;
  @override
  final String mediaId;

  factory _$SaveStickerEntryRequest(
          [void Function(SaveStickerEntryRequestBuilder)? updates]) =>
      (SaveStickerEntryRequestBuilder()..update(updates))._build();

  _$SaveStickerEntryRequest._(
      {required this.packId,
      required this.contentHash,
      required this.body,
      required this.encryptedFile,
      this.info,
      this.thumbnailEncryptedFile,
      this.thumbnailInfo,
      this.animated,
      required this.sizeBytes,
      required this.mxcUri,
      required this.mediaId})
      : super._();
  @override
  SaveStickerEntryRequest rebuild(
          void Function(SaveStickerEntryRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SaveStickerEntryRequestBuilder toBuilder() =>
      SaveStickerEntryRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SaveStickerEntryRequest &&
        packId == other.packId &&
        contentHash == other.contentHash &&
        body == other.body &&
        encryptedFile == other.encryptedFile &&
        info == other.info &&
        thumbnailEncryptedFile == other.thumbnailEncryptedFile &&
        thumbnailInfo == other.thumbnailInfo &&
        animated == other.animated &&
        sizeBytes == other.sizeBytes &&
        mxcUri == other.mxcUri &&
        mediaId == other.mediaId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, packId.hashCode);
    _$hash = $jc(_$hash, contentHash.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, encryptedFile.hashCode);
    _$hash = $jc(_$hash, info.hashCode);
    _$hash = $jc(_$hash, thumbnailEncryptedFile.hashCode);
    _$hash = $jc(_$hash, thumbnailInfo.hashCode);
    _$hash = $jc(_$hash, animated.hashCode);
    _$hash = $jc(_$hash, sizeBytes.hashCode);
    _$hash = $jc(_$hash, mxcUri.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SaveStickerEntryRequest')
          ..add('packId', packId)
          ..add('contentHash', contentHash)
          ..add('body', body)
          ..add('encryptedFile', encryptedFile)
          ..add('info', info)
          ..add('thumbnailEncryptedFile', thumbnailEncryptedFile)
          ..add('thumbnailInfo', thumbnailInfo)
          ..add('animated', animated)
          ..add('sizeBytes', sizeBytes)
          ..add('mxcUri', mxcUri)
          ..add('mediaId', mediaId))
        .toString();
  }
}

class SaveStickerEntryRequestBuilder
    implements
        Builder<SaveStickerEntryRequest, SaveStickerEntryRequestBuilder> {
  _$SaveStickerEntryRequest? _$v;

  String? _packId;
  String? get packId => _$this._packId;
  set packId(String? packId) => _$this._packId = packId;

  String? _contentHash;
  String? get contentHash => _$this._contentHash;
  set contentHash(String? contentHash) => _$this._contentHash = contentHash;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  MapBuilder<String, JsonObject?>? _encryptedFile;
  MapBuilder<String, JsonObject?> get encryptedFile =>
      _$this._encryptedFile ??= MapBuilder<String, JsonObject?>();
  set encryptedFile(MapBuilder<String, JsonObject?>? encryptedFile) =>
      _$this._encryptedFile = encryptedFile;

  MapBuilder<String, JsonObject?>? _info;
  MapBuilder<String, JsonObject?> get info =>
      _$this._info ??= MapBuilder<String, JsonObject?>();
  set info(MapBuilder<String, JsonObject?>? info) => _$this._info = info;

  MapBuilder<String, JsonObject?>? _thumbnailEncryptedFile;
  MapBuilder<String, JsonObject?> get thumbnailEncryptedFile =>
      _$this._thumbnailEncryptedFile ??= MapBuilder<String, JsonObject?>();
  set thumbnailEncryptedFile(
          MapBuilder<String, JsonObject?>? thumbnailEncryptedFile) =>
      _$this._thumbnailEncryptedFile = thumbnailEncryptedFile;

  MapBuilder<String, JsonObject?>? _thumbnailInfo;
  MapBuilder<String, JsonObject?> get thumbnailInfo =>
      _$this._thumbnailInfo ??= MapBuilder<String, JsonObject?>();
  set thumbnailInfo(MapBuilder<String, JsonObject?>? thumbnailInfo) =>
      _$this._thumbnailInfo = thumbnailInfo;

  bool? _animated;
  bool? get animated => _$this._animated;
  set animated(bool? animated) => _$this._animated = animated;

  int? _sizeBytes;
  int? get sizeBytes => _$this._sizeBytes;
  set sizeBytes(int? sizeBytes) => _$this._sizeBytes = sizeBytes;

  String? _mxcUri;
  String? get mxcUri => _$this._mxcUri;
  set mxcUri(String? mxcUri) => _$this._mxcUri = mxcUri;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  SaveStickerEntryRequestBuilder() {
    SaveStickerEntryRequest._defaults(this);
  }

  SaveStickerEntryRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _packId = $v.packId;
      _contentHash = $v.contentHash;
      _body = $v.body;
      _encryptedFile = $v.encryptedFile.toBuilder();
      _info = $v.info?.toBuilder();
      _thumbnailEncryptedFile = $v.thumbnailEncryptedFile?.toBuilder();
      _thumbnailInfo = $v.thumbnailInfo?.toBuilder();
      _animated = $v.animated;
      _sizeBytes = $v.sizeBytes;
      _mxcUri = $v.mxcUri;
      _mediaId = $v.mediaId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SaveStickerEntryRequest other) {
    _$v = other as _$SaveStickerEntryRequest;
  }

  @override
  void update(void Function(SaveStickerEntryRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SaveStickerEntryRequest build() => _build();

  _$SaveStickerEntryRequest _build() {
    _$SaveStickerEntryRequest _$result;
    try {
      _$result = _$v ??
          _$SaveStickerEntryRequest._(
            packId: BuiltValueNullFieldError.checkNotNull(
                packId, r'SaveStickerEntryRequest', 'packId'),
            contentHash: BuiltValueNullFieldError.checkNotNull(
                contentHash, r'SaveStickerEntryRequest', 'contentHash'),
            body: BuiltValueNullFieldError.checkNotNull(
                body, r'SaveStickerEntryRequest', 'body'),
            encryptedFile: encryptedFile.build(),
            info: _info?.build(),
            thumbnailEncryptedFile: _thumbnailEncryptedFile?.build(),
            thumbnailInfo: _thumbnailInfo?.build(),
            animated: animated,
            sizeBytes: BuiltValueNullFieldError.checkNotNull(
                sizeBytes, r'SaveStickerEntryRequest', 'sizeBytes'),
            mxcUri: BuiltValueNullFieldError.checkNotNull(
                mxcUri, r'SaveStickerEntryRequest', 'mxcUri'),
            mediaId: BuiltValueNullFieldError.checkNotNull(
                mediaId, r'SaveStickerEntryRequest', 'mediaId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'encryptedFile';
        encryptedFile.build();
        _$failedField = 'info';
        _info?.build();
        _$failedField = 'thumbnailEncryptedFile';
        _thumbnailEncryptedFile?.build();
        _$failedField = 'thumbnailInfo';
        _thumbnailInfo?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SaveStickerEntryRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
