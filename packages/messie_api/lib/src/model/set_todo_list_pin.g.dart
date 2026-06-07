// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_todo_list_pin.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SetTodoListPin extends SetTodoListPin {
  @override
  final bool pinned;

  factory _$SetTodoListPin([void Function(SetTodoListPinBuilder)? updates]) =>
      (SetTodoListPinBuilder()..update(updates))._build();

  _$SetTodoListPin._({required this.pinned}) : super._();
  @override
  SetTodoListPin rebuild(void Function(SetTodoListPinBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SetTodoListPinBuilder toBuilder() => SetTodoListPinBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SetTodoListPin && pinned == other.pinned;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pinned.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SetTodoListPin')
          ..add('pinned', pinned))
        .toString();
  }
}

class SetTodoListPinBuilder
    implements Builder<SetTodoListPin, SetTodoListPinBuilder> {
  _$SetTodoListPin? _$v;

  bool? _pinned;
  bool? get pinned => _$this._pinned;
  set pinned(bool? pinned) => _$this._pinned = pinned;

  SetTodoListPinBuilder() {
    SetTodoListPin._defaults(this);
  }

  SetTodoListPinBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pinned = $v.pinned;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SetTodoListPin other) {
    _$v = other as _$SetTodoListPin;
  }

  @override
  void update(void Function(SetTodoListPinBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SetTodoListPin build() => _build();

  _$SetTodoListPin _build() {
    final _$result = _$v ??
        _$SetTodoListPin._(
          pinned: BuiltValueNullFieldError.checkNotNull(
              pinned, r'SetTodoListPin', 'pinned'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
