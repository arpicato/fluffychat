import 'package:fluffychat/services/bridge_room_presentation.dart';
import 'package:fluffychat/services/messie_bridge_service.dart';
import 'package:matrix/matrix.dart';

class BridgeRoomMapping {
  const BridgeRoomMapping._();

  static Map<String, int> loginCountByProvider(
    List<MessieBridgeLoginInfo> bridgeLogins,
  ) {
    final counts = <String, Set<String>>{};
    for (final mapping in bridgeLogins) {
      counts.putIfAbsent(mapping.provider, () => <String>{}).add(mapping.loginId);
    }
    return counts.map((provider, ids) => MapEntry(provider, ids.length));
  }

  static MessieBridgeLoginInfo? loginForRoom(
    Room room,
    List<MessieBridgeLoginInfo> bridgeLogins,
  ) {
    final parentIds = {
      ...room.spaceParents.map((parent) => parent.roomId).whereType<String>(),
      ...room.client.rooms
          .where(
            (space) =>
                space.isSpace &&
                space.spaceChildren.any((child) => child.roomId == room.id),
          )
          .map((space) => space.id),
    };
    if (parentIds.isEmpty) return null;
    for (final login in bridgeLogins) {
      final spaceRoom = login.spaceRoom;
      if (spaceRoom != null && parentIds.contains(spaceRoom)) return login;
    }
    return null;
  }

  static BridgeRoomPresentation presentationForRoom(
    Room room,
    BridgeProviderCatalog bridgeProviderCatalog,
    List<MessieBridgeLoginInfo> bridgeLogins,
  ) {
    final roomMapping = loginForRoom(room, bridgeLogins);
    final loginCounts = loginCountByProvider(bridgeLogins);
    final provider = roomMapping?.provider ?? '';
    return BridgeRoomPresentation.fromRoom(
      room,
      bridgeProviderCatalog,
      roomMapping: roomMapping,
      loginCountForProvider: loginCounts[provider] ?? 0,
      showLoginNumberBadge: (loginCounts[provider] ?? 0) > 1,
    );
  }
}
