// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_room_mapping.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BridgeRoomMapping extends BridgeRoomMapping {
  @override
  final String provider;
  @override
  final String roomId;
  @override
  final String loginId;
  @override
  final String? loginName;
  @override
  final String? spaceRoom;
  @override
  final bool? preferred;

  factory _$BridgeRoomMapping(
          [void Function(BridgeRoomMappingBuilder)? updates]) =>
      (BridgeRoomMappingBuilder()..update(updates))._build();

  _$BridgeRoomMapping._(
      {required this.provider,
      required this.roomId,
      required this.loginId,
      this.loginName,
      this.spaceRoom,
      this.preferred})
      : super._();
  @override
  BridgeRoomMapping rebuild(void Function(BridgeRoomMappingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BridgeRoomMappingBuilder toBuilder() =>
      BridgeRoomMappingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BridgeRoomMapping &&
        provider == other.provider &&
        roomId == other.roomId &&
        loginId == other.loginId &&
        loginName == other.loginName &&
        spaceRoom == other.spaceRoom &&
        preferred == other.preferred;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, roomId.hashCode);
    _$hash = $jc(_$hash, loginId.hashCode);
    _$hash = $jc(_$hash, loginName.hashCode);
    _$hash = $jc(_$hash, spaceRoom.hashCode);
    _$hash = $jc(_$hash, preferred.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BridgeRoomMapping')
          ..add('provider', provider)
          ..add('roomId', roomId)
          ..add('loginId', loginId)
          ..add('loginName', loginName)
          ..add('spaceRoom', spaceRoom)
          ..add('preferred', preferred))
        .toString();
  }
}

class BridgeRoomMappingBuilder
    implements Builder<BridgeRoomMapping, BridgeRoomMappingBuilder> {
  _$BridgeRoomMapping? _$v;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _roomId;
  String? get roomId => _$this._roomId;
  set roomId(String? roomId) => _$this._roomId = roomId;

  String? _loginId;
  String? get loginId => _$this._loginId;
  set loginId(String? loginId) => _$this._loginId = loginId;

  String? _loginName;
  String? get loginName => _$this._loginName;
  set loginName(String? loginName) => _$this._loginName = loginName;

  String? _spaceRoom;
  String? get spaceRoom => _$this._spaceRoom;
  set spaceRoom(String? spaceRoom) => _$this._spaceRoom = spaceRoom;

  bool? _preferred;
  bool? get preferred => _$this._preferred;
  set preferred(bool? preferred) => _$this._preferred = preferred;

  BridgeRoomMappingBuilder() {
    BridgeRoomMapping._defaults(this);
  }

  BridgeRoomMappingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _provider = $v.provider;
      _roomId = $v.roomId;
      _loginId = $v.loginId;
      _loginName = $v.loginName;
      _spaceRoom = $v.spaceRoom;
      _preferred = $v.preferred;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BridgeRoomMapping other) {
    _$v = other as _$BridgeRoomMapping;
  }

  @override
  void update(void Function(BridgeRoomMappingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BridgeRoomMapping build() => _build();

  _$BridgeRoomMapping _build() {
    final _$result = _$v ??
        _$BridgeRoomMapping._(
          provider: BuiltValueNullFieldError.checkNotNull(
              provider, r'BridgeRoomMapping', 'provider'),
          roomId: BuiltValueNullFieldError.checkNotNull(
              roomId, r'BridgeRoomMapping', 'roomId'),
          loginId: BuiltValueNullFieldError.checkNotNull(
              loginId, r'BridgeRoomMapping', 'loginId'),
          loginName: loginName,
          spaceRoom: spaceRoom,
          preferred: preferred,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
