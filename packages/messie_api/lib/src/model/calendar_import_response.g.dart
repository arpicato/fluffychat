// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_import_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CalendarImportResponse extends CalendarImportResponse {
  @override
  final CalendarSource source_;
  @override
  final int importedEventCount;

  factory _$CalendarImportResponse(
          [void Function(CalendarImportResponseBuilder)? updates]) =>
      (CalendarImportResponseBuilder()..update(updates))._build();

  _$CalendarImportResponse._(
      {required this.source_, required this.importedEventCount})
      : super._();
  @override
  CalendarImportResponse rebuild(
          void Function(CalendarImportResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CalendarImportResponseBuilder toBuilder() =>
      CalendarImportResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CalendarImportResponse &&
        source_ == other.source_ &&
        importedEventCount == other.importedEventCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, importedEventCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CalendarImportResponse')
          ..add('source_', source_)
          ..add('importedEventCount', importedEventCount))
        .toString();
  }
}

class CalendarImportResponseBuilder
    implements Builder<CalendarImportResponse, CalendarImportResponseBuilder> {
  _$CalendarImportResponse? _$v;

  CalendarSourceBuilder? _source_;
  CalendarSourceBuilder get source_ =>
      _$this._source_ ??= CalendarSourceBuilder();
  set source_(CalendarSourceBuilder? source_) => _$this._source_ = source_;

  int? _importedEventCount;
  int? get importedEventCount => _$this._importedEventCount;
  set importedEventCount(int? importedEventCount) =>
      _$this._importedEventCount = importedEventCount;

  CalendarImportResponseBuilder() {
    CalendarImportResponse._defaults(this);
  }

  CalendarImportResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _source_ = $v.source_.toBuilder();
      _importedEventCount = $v.importedEventCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CalendarImportResponse other) {
    _$v = other as _$CalendarImportResponse;
  }

  @override
  void update(void Function(CalendarImportResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CalendarImportResponse build() => _build();

  _$CalendarImportResponse _build() {
    _$CalendarImportResponse _$result;
    try {
      _$result = _$v ??
          _$CalendarImportResponse._(
            source_: source_.build(),
            importedEventCount: BuiltValueNullFieldError.checkNotNull(
                importedEventCount,
                r'CalendarImportResponse',
                'importedEventCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'source_';
        source_.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CalendarImportResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
