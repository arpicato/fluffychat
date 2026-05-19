// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_source.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CalendarSource extends CalendarSource {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String kind;
  @override
  final String displayName;
  @override
  final String category;
  @override
  final String importMode;
  @override
  final String? sourceUrl;
  @override
  final String refreshState;
  @override
  final DateTime? lastSyncedAt;
  @override
  final DateTime? lastRefreshAttemptAt;
  @override
  final String? lastRefreshError;
  @override
  final String? etag;
  @override
  final DateTime? lastModified;
  @override
  final DateTime? nextRefreshAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$CalendarSource([void Function(CalendarSourceBuilder)? updates]) =>
      (CalendarSourceBuilder()..update(updates))._build();

  _$CalendarSource._(
      {required this.id,
      required this.userId,
      required this.kind,
      required this.displayName,
      required this.category,
      required this.importMode,
      this.sourceUrl,
      required this.refreshState,
      this.lastSyncedAt,
      this.lastRefreshAttemptAt,
      this.lastRefreshError,
      this.etag,
      this.lastModified,
      this.nextRefreshAt,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  CalendarSource rebuild(void Function(CalendarSourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CalendarSourceBuilder toBuilder() => CalendarSourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CalendarSource &&
        id == other.id &&
        userId == other.userId &&
        kind == other.kind &&
        displayName == other.displayName &&
        category == other.category &&
        importMode == other.importMode &&
        sourceUrl == other.sourceUrl &&
        refreshState == other.refreshState &&
        lastSyncedAt == other.lastSyncedAt &&
        lastRefreshAttemptAt == other.lastRefreshAttemptAt &&
        lastRefreshError == other.lastRefreshError &&
        etag == other.etag &&
        lastModified == other.lastModified &&
        nextRefreshAt == other.nextRefreshAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, importMode.hashCode);
    _$hash = $jc(_$hash, sourceUrl.hashCode);
    _$hash = $jc(_$hash, refreshState.hashCode);
    _$hash = $jc(_$hash, lastSyncedAt.hashCode);
    _$hash = $jc(_$hash, lastRefreshAttemptAt.hashCode);
    _$hash = $jc(_$hash, lastRefreshError.hashCode);
    _$hash = $jc(_$hash, etag.hashCode);
    _$hash = $jc(_$hash, lastModified.hashCode);
    _$hash = $jc(_$hash, nextRefreshAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CalendarSource')
          ..add('id', id)
          ..add('userId', userId)
          ..add('kind', kind)
          ..add('displayName', displayName)
          ..add('category', category)
          ..add('importMode', importMode)
          ..add('sourceUrl', sourceUrl)
          ..add('refreshState', refreshState)
          ..add('lastSyncedAt', lastSyncedAt)
          ..add('lastRefreshAttemptAt', lastRefreshAttemptAt)
          ..add('lastRefreshError', lastRefreshError)
          ..add('etag', etag)
          ..add('lastModified', lastModified)
          ..add('nextRefreshAt', nextRefreshAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CalendarSourceBuilder
    implements Builder<CalendarSource, CalendarSourceBuilder> {
  _$CalendarSource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _kind;
  String? get kind => _$this._kind;
  set kind(String? kind) => _$this._kind = kind;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  String? _importMode;
  String? get importMode => _$this._importMode;
  set importMode(String? importMode) => _$this._importMode = importMode;

  String? _sourceUrl;
  String? get sourceUrl => _$this._sourceUrl;
  set sourceUrl(String? sourceUrl) => _$this._sourceUrl = sourceUrl;

  String? _refreshState;
  String? get refreshState => _$this._refreshState;
  set refreshState(String? refreshState) => _$this._refreshState = refreshState;

  DateTime? _lastSyncedAt;
  DateTime? get lastSyncedAt => _$this._lastSyncedAt;
  set lastSyncedAt(DateTime? lastSyncedAt) =>
      _$this._lastSyncedAt = lastSyncedAt;

  DateTime? _lastRefreshAttemptAt;
  DateTime? get lastRefreshAttemptAt => _$this._lastRefreshAttemptAt;
  set lastRefreshAttemptAt(DateTime? lastRefreshAttemptAt) =>
      _$this._lastRefreshAttemptAt = lastRefreshAttemptAt;

  String? _lastRefreshError;
  String? get lastRefreshError => _$this._lastRefreshError;
  set lastRefreshError(String? lastRefreshError) =>
      _$this._lastRefreshError = lastRefreshError;

  String? _etag;
  String? get etag => _$this._etag;
  set etag(String? etag) => _$this._etag = etag;

  DateTime? _lastModified;
  DateTime? get lastModified => _$this._lastModified;
  set lastModified(DateTime? lastModified) =>
      _$this._lastModified = lastModified;

  DateTime? _nextRefreshAt;
  DateTime? get nextRefreshAt => _$this._nextRefreshAt;
  set nextRefreshAt(DateTime? nextRefreshAt) =>
      _$this._nextRefreshAt = nextRefreshAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CalendarSourceBuilder() {
    CalendarSource._defaults(this);
  }

  CalendarSourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _kind = $v.kind;
      _displayName = $v.displayName;
      _category = $v.category;
      _importMode = $v.importMode;
      _sourceUrl = $v.sourceUrl;
      _refreshState = $v.refreshState;
      _lastSyncedAt = $v.lastSyncedAt;
      _lastRefreshAttemptAt = $v.lastRefreshAttemptAt;
      _lastRefreshError = $v.lastRefreshError;
      _etag = $v.etag;
      _lastModified = $v.lastModified;
      _nextRefreshAt = $v.nextRefreshAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CalendarSource other) {
    _$v = other as _$CalendarSource;
  }

  @override
  void update(void Function(CalendarSourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CalendarSource build() => _build();

  _$CalendarSource _build() {
    final _$result = _$v ??
        _$CalendarSource._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CalendarSource', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'CalendarSource', 'userId'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'CalendarSource', 'kind'),
          category: BuiltValueNullFieldError.checkNotNull(
              category, r'CalendarSource', 'category'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'CalendarSource', 'displayName'),
          importMode: BuiltValueNullFieldError.checkNotNull(
              importMode, r'CalendarSource', 'importMode'),
          sourceUrl: sourceUrl,
          refreshState: BuiltValueNullFieldError.checkNotNull(
              refreshState, r'CalendarSource', 'refreshState'),
          lastSyncedAt: lastSyncedAt,
          lastRefreshAttemptAt: lastRefreshAttemptAt,
          lastRefreshError: lastRefreshError,
          etag: etag,
          lastModified: lastModified,
          nextRefreshAt: nextRefreshAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
