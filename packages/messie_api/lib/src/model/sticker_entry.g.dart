// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StickerEntry extends StickerEntry {
  @override
  final String id;
  @override
  final String code;
  @override
  final String body;
  @override
  final String contentHash;
  @override
  final int createdAt;
  @override
  final BuiltMap<String, JsonObject?> file;
  @override
  final BuiltMap<String, JsonObject?> info;
  @override
  final BuiltMap<String, JsonObject?>? thumbnailFile;
  @override
  final BuiltMap<String, JsonObject?>? thumbnailInfo;
  @override
  final bool? animated;
  @override
  final BuiltList<String> packIds;

  factory _$StickerEntry([void Function(StickerEntryBuilder)? updates]) =>
      (StickerEntryBuilder()..update(updates))._build();

  _$StickerEntry._(
      {required this.id,
      required this.code,
      required this.body,
      required this.contentHash,
      required this.createdAt,
      required this.file,
      required this.info,
      this.thumbnailFile,
      this.thumbnailInfo,
      this.animated,
      required this.packIds})
      : super._();
  @override
  StickerEntry rebuild(void Function(StickerEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StickerEntryBuilder toBuilder() => StickerEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickerEntry &&
        id == other.id &&
        code == other.code &&
        body == other.body &&
        contentHash == other.contentHash &&
        createdAt == other.createdAt &&
        file == other.file &&
        info == other.info &&
        thumbnailFile == other.thumbnailFile &&
        thumbnailInfo == other.thumbnailInfo &&
        animated == other.animated &&
        packIds == other.packIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, contentHash.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, file.hashCode);
    _$hash = $jc(_$hash, info.hashCode);
    _$hash = $jc(_$hash, thumbnailFile.hashCode);
    _$hash = $jc(_$hash, thumbnailInfo.hashCode);
    _$hash = $jc(_$hash, animated.hashCode);
    _$hash = $jc(_$hash, packIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StickerEntry')
          ..add('id', id)
          ..add('code', code)
          ..add('body', body)
          ..add('contentHash', contentHash)
          ..add('createdAt', createdAt)
          ..add('file', file)
          ..add('info', info)
          ..add('thumbnailFile', thumbnailFile)
          ..add('thumbnailInfo', thumbnailInfo)
          ..add('animated', animated)
          ..add('packIds', packIds))
        .toString();
  }
}

class StickerEntryBuilder
    implements Builder<StickerEntry, StickerEntryBuilder> {
  _$StickerEntry? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  String? _contentHash;
  String? get contentHash => _$this._contentHash;
  set contentHash(String? contentHash) => _$this._contentHash = contentHash;

  int? _createdAt;
  int? get createdAt => _$this._createdAt;
  set createdAt(int? createdAt) => _$this._createdAt = createdAt;

  MapBuilder<String, JsonObject?>? _file;
  MapBuilder<String, JsonObject?> get file =>
      _$this._file ??= MapBuilder<String, JsonObject?>();
  set file(MapBuilder<String, JsonObject?>? file) => _$this._file = file;

  MapBuilder<String, JsonObject?>? _info;
  MapBuilder<String, JsonObject?> get info =>
      _$this._info ??= MapBuilder<String, JsonObject?>();
  set info(MapBuilder<String, JsonObject?>? info) => _$this._info = info;

  MapBuilder<String, JsonObject?>? _thumbnailFile;
  MapBuilder<String, JsonObject?> get thumbnailFile =>
      _$this._thumbnailFile ??= MapBuilder<String, JsonObject?>();
  set thumbnailFile(MapBuilder<String, JsonObject?>? thumbnailFile) =>
      _$this._thumbnailFile = thumbnailFile;

  MapBuilder<String, JsonObject?>? _thumbnailInfo;
  MapBuilder<String, JsonObject?> get thumbnailInfo =>
      _$this._thumbnailInfo ??= MapBuilder<String, JsonObject?>();
  set thumbnailInfo(MapBuilder<String, JsonObject?>? thumbnailInfo) =>
      _$this._thumbnailInfo = thumbnailInfo;

  bool? _animated;
  bool? get animated => _$this._animated;
  set animated(bool? animated) => _$this._animated = animated;

  ListBuilder<String>? _packIds;
  ListBuilder<String> get packIds => _$this._packIds ??= ListBuilder<String>();
  set packIds(ListBuilder<String>? packIds) => _$this._packIds = packIds;

  StickerEntryBuilder() {
    StickerEntry._defaults(this);
  }

  StickerEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _code = $v.code;
      _body = $v.body;
      _contentHash = $v.contentHash;
      _createdAt = $v.createdAt;
      _file = $v.file.toBuilder();
      _info = $v.info.toBuilder();
      _thumbnailFile = $v.thumbnailFile?.toBuilder();
      _thumbnailInfo = $v.thumbnailInfo?.toBuilder();
      _animated = $v.animated;
      _packIds = $v.packIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StickerEntry other) {
    _$v = other as _$StickerEntry;
  }

  @override
  void update(void Function(StickerEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickerEntry build() => _build();

  _$StickerEntry _build() {
    _$StickerEntry _$result;
    try {
      _$result = _$v ??
          _$StickerEntry._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'StickerEntry', 'id'),
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'StickerEntry', 'code'),
            body: BuiltValueNullFieldError.checkNotNull(
                body, r'StickerEntry', 'body'),
            contentHash: BuiltValueNullFieldError.checkNotNull(
                contentHash, r'StickerEntry', 'contentHash'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'StickerEntry', 'createdAt'),
            file: file.build(),
            info: info.build(),
            thumbnailFile: _thumbnailFile?.build(),
            thumbnailInfo: _thumbnailInfo?.build(),
            animated: animated,
            packIds: packIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'file';
        file.build();
        _$failedField = 'info';
        info.build();
        _$failedField = 'thumbnailFile';
        _thumbnailFile?.build();
        _$failedField = 'thumbnailInfo';
        _thumbnailInfo?.build();

        _$failedField = 'packIds';
        packIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StickerEntry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
