// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_pack.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StickerPack extends StickerPack {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$StickerPack([void Function(StickerPackBuilder)? updates]) =>
      (StickerPackBuilder()..update(updates))._build();

  _$StickerPack._(
      {required this.id,
      required this.userId,
      required this.name,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  StickerPack rebuild(void Function(StickerPackBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StickerPackBuilder toBuilder() => StickerPackBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickerPack &&
        id == other.id &&
        userId == other.userId &&
        name == other.name &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StickerPack')
          ..add('id', id)
          ..add('userId', userId)
          ..add('name', name)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class StickerPackBuilder implements Builder<StickerPack, StickerPackBuilder> {
  _$StickerPack? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  StickerPackBuilder() {
    StickerPack._defaults(this);
  }

  StickerPackBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _name = $v.name;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StickerPack other) {
    _$v = other as _$StickerPack;
  }

  @override
  void update(void Function(StickerPackBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickerPack build() => _build();

  _$StickerPack _build() {
    final _$result = _$v ??
        _$StickerPack._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'StickerPack', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'StickerPack', 'userId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'StickerPack', 'name'),
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
