// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_entry_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StickerEntryListResponse extends StickerEntryListResponse {
  @override
  final BuiltList<StickerEntry> entries;

  factory _$StickerEntryListResponse(
          [void Function(StickerEntryListResponseBuilder)? updates]) =>
      (StickerEntryListResponseBuilder()..update(updates))._build();

  _$StickerEntryListResponse._({required this.entries}) : super._();
  @override
  StickerEntryListResponse rebuild(
          void Function(StickerEntryListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StickerEntryListResponseBuilder toBuilder() =>
      StickerEntryListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickerEntryListResponse && entries == other.entries;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StickerEntryListResponse')
          ..add('entries', entries))
        .toString();
  }
}

class StickerEntryListResponseBuilder
    implements
        Builder<StickerEntryListResponse, StickerEntryListResponseBuilder> {
  _$StickerEntryListResponse? _$v;

  ListBuilder<StickerEntry>? _entries;
  ListBuilder<StickerEntry> get entries =>
      _$this._entries ??= ListBuilder<StickerEntry>();
  set entries(ListBuilder<StickerEntry>? entries) => _$this._entries = entries;

  StickerEntryListResponseBuilder() {
    StickerEntryListResponse._defaults(this);
  }

  StickerEntryListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entries = $v.entries.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StickerEntryListResponse other) {
    _$v = other as _$StickerEntryListResponse;
  }

  @override
  void update(void Function(StickerEntryListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickerEntryListResponse build() => _build();

  _$StickerEntryListResponse _build() {
    _$StickerEntryListResponse _$result;
    try {
      _$result = _$v ??
          _$StickerEntryListResponse._(
            entries: entries.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entries';
        entries.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StickerEntryListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
