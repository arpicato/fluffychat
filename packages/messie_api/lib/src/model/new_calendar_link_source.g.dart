// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_calendar_link_source.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NewCalendarLinkSource extends NewCalendarLinkSource {
  @override
  final String url;
  @override
  final String? category;
  @override
  final String? displayName;

  factory _$NewCalendarLinkSource(
          [void Function(NewCalendarLinkSourceBuilder)? updates]) =>
      (NewCalendarLinkSourceBuilder()..update(updates))._build();

  _$NewCalendarLinkSource._({required this.url, this.category, this.displayName})
      : super._();
  @override
  NewCalendarLinkSource rebuild(
          void Function(NewCalendarLinkSourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NewCalendarLinkSourceBuilder toBuilder() =>
      NewCalendarLinkSourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NewCalendarLinkSource &&
        url == other.url &&
        category == other.category &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NewCalendarLinkSource')
          ..add('url', url)
          ..add('category', category)
          ..add('displayName', displayName))
        .toString();
  }
}

class NewCalendarLinkSourceBuilder
    implements Builder<NewCalendarLinkSource, NewCalendarLinkSourceBuilder> {
  _$NewCalendarLinkSource? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  NewCalendarLinkSourceBuilder() {
    NewCalendarLinkSource._defaults(this);
  }

  NewCalendarLinkSourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _category = $v.category;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NewCalendarLinkSource other) {
    _$v = other as _$NewCalendarLinkSource;
  }

  @override
  void update(void Function(NewCalendarLinkSourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NewCalendarLinkSource build() => _build();

  _$NewCalendarLinkSource _build() {
    final _$result = _$v ??
        _$NewCalendarLinkSource._(
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'NewCalendarLinkSource', 'url'),
          category: category,
          displayName: displayName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
