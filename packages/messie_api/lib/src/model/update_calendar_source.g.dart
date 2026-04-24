// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_calendar_source.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateCalendarSource extends UpdateCalendarSource {
  @override
  final String? category;
  @override
  final String? displayName;

  factory _$UpdateCalendarSource(
          [void Function(UpdateCalendarSourceBuilder)? updates]) =>
      (UpdateCalendarSourceBuilder()..update(updates))._build();

  _$UpdateCalendarSource._({this.category, this.displayName}) : super._();
  @override
  UpdateCalendarSource rebuild(
          void Function(UpdateCalendarSourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateCalendarSourceBuilder toBuilder() =>
      UpdateCalendarSourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateCalendarSource &&
        category == other.category &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateCalendarSource')
          ..add('category', category)
          ..add('displayName', displayName))
        .toString();
  }
}

class UpdateCalendarSourceBuilder
    implements Builder<UpdateCalendarSource, UpdateCalendarSourceBuilder> {
  _$UpdateCalendarSource? _$v;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  UpdateCalendarSourceBuilder() {
    UpdateCalendarSource._defaults(this);
  }

  UpdateCalendarSourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateCalendarSource other) {
    _$v = other as _$UpdateCalendarSource;
  }

  @override
  void update(void Function(UpdateCalendarSourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateCalendarSource build() => _build();

  _$UpdateCalendarSource _build() {
    final _$result = _$v ??
        _$UpdateCalendarSource._(
          category: category,
          displayName: displayName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
