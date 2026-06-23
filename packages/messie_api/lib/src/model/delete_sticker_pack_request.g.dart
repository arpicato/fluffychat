// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_sticker_pack_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeleteStickerPackRequestModeEnum
    _$deleteStickerPackRequestModeEnum_moveToSaved =
    const DeleteStickerPackRequestModeEnum._('moveToSaved');
const DeleteStickerPackRequestModeEnum
    _$deleteStickerPackRequestModeEnum_deleteStickers =
    const DeleteStickerPackRequestModeEnum._('deleteStickers');

DeleteStickerPackRequestModeEnum _$deleteStickerPackRequestModeEnumValueOf(
    String name) {
  switch (name) {
    case 'moveToSaved':
      return _$deleteStickerPackRequestModeEnum_moveToSaved;
    case 'deleteStickers':
      return _$deleteStickerPackRequestModeEnum_deleteStickers;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeleteStickerPackRequestModeEnum>
    _$deleteStickerPackRequestModeEnumValues = BuiltSet<
        DeleteStickerPackRequestModeEnum>(const <DeleteStickerPackRequestModeEnum>[
  _$deleteStickerPackRequestModeEnum_moveToSaved,
  _$deleteStickerPackRequestModeEnum_deleteStickers,
]);

Serializer<DeleteStickerPackRequestModeEnum>
    _$deleteStickerPackRequestModeEnumSerializer =
    _$DeleteStickerPackRequestModeEnumSerializer();

class _$DeleteStickerPackRequestModeEnumSerializer
    implements PrimitiveSerializer<DeleteStickerPackRequestModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'moveToSaved': 'move_to_saved',
    'deleteStickers': 'delete_stickers',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'move_to_saved': 'moveToSaved',
    'delete_stickers': 'deleteStickers',
  };

  @override
  final Iterable<Type> types = const <Type>[DeleteStickerPackRequestModeEnum];
  @override
  final String wireName = 'DeleteStickerPackRequestModeEnum';

  @override
  Object serialize(
          Serializers serializers, DeleteStickerPackRequestModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeleteStickerPackRequestModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeleteStickerPackRequestModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeleteStickerPackRequest extends DeleteStickerPackRequest {
  @override
  final DeleteStickerPackRequestModeEnum? mode;

  factory _$DeleteStickerPackRequest(
          [void Function(DeleteStickerPackRequestBuilder)? updates]) =>
      (DeleteStickerPackRequestBuilder()..update(updates))._build();

  _$DeleteStickerPackRequest._({this.mode}) : super._();
  @override
  DeleteStickerPackRequest rebuild(
          void Function(DeleteStickerPackRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteStickerPackRequestBuilder toBuilder() =>
      DeleteStickerPackRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteStickerPackRequest && mode == other.mode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteStickerPackRequest')
          ..add('mode', mode))
        .toString();
  }
}

class DeleteStickerPackRequestBuilder
    implements
        Builder<DeleteStickerPackRequest, DeleteStickerPackRequestBuilder> {
  _$DeleteStickerPackRequest? _$v;

  DeleteStickerPackRequestModeEnum? _mode;
  DeleteStickerPackRequestModeEnum? get mode => _$this._mode;
  set mode(DeleteStickerPackRequestModeEnum? mode) => _$this._mode = mode;

  DeleteStickerPackRequestBuilder() {
    DeleteStickerPackRequest._defaults(this);
  }

  DeleteStickerPackRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mode = $v.mode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteStickerPackRequest other) {
    _$v = other as _$DeleteStickerPackRequest;
  }

  @override
  void update(void Function(DeleteStickerPackRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteStickerPackRequest build() => _build();

  _$DeleteStickerPackRequest _build() {
    final _$result = _$v ??
        _$DeleteStickerPackRequest._(
          mode: mode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
