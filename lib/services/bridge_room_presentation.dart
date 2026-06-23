import 'dart:math' as math;

import 'package:fluffychat/services/messie_bridge_service.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class BridgeProviderDefinition {
  const BridgeProviderDefinition({
    required this.provider,
    required this.badgeIcon,
    required this.badgeColor,
    required this.fallbackBridgeBotLocalpart,
    required this.remoteUserLocalpartPrefixes,
  });

  final String provider;
  final IconData badgeIcon;
  final Color badgeColor;
  final String fallbackBridgeBotLocalpart;
  final List<String> remoteUserLocalpartPrefixes;

  bool matchesRemoteUserId(String userId) {
    final localpart = userId.localpart;
    if (localpart == null) return false;
    return remoteUserLocalpartPrefixes.any(localpart.startsWith);
  }

  bool matchesBridgeBotId(String userId, {String? bridgeBotId}) {
    if (bridgeBotId != null && bridgeBotId == userId) return true;
    final localpart = userId.localpart;
    return localpart == fallbackBridgeBotLocalpart;
  }
}

class BridgeProviderCatalog {
  const BridgeProviderCatalog._({
    required this.definitions,
    required this.bridgeBotIdsByProvider,
  });

  const BridgeProviderCatalog.empty()
    : definitions = supportedProviders,
      bridgeBotIdsByProvider = const {};

  final Map<String, BridgeProviderDefinition> definitions;
  final Map<String, String> bridgeBotIdsByProvider;

  static const Map<String, BridgeProviderDefinition> supportedProviders = {
    'whatsapp': BridgeProviderDefinition(
      provider: 'whatsapp',
      badgeIcon: Icons.message,
      badgeColor: Color(0xFF25D366),
      fallbackBridgeBotLocalpart: 'whatsappbot',
      remoteUserLocalpartPrefixes: ['whatsapp_'],
    ),
  };

  String? bridgeBotIdFor(String provider) => bridgeBotIdsByProvider[provider];

  BridgeProviderDefinition? providerForRemoteUserId(String userId) {
    for (final definition in definitions.values) {
      if (definition.matchesRemoteUserId(userId)) return definition;
    }
    return null;
  }

  factory BridgeProviderCatalog.fromStates(
    Iterable<MessieBridgeState> states,
  ) {
    final bridgeBotIdsByProvider = <String, String>{};
    for (final state in states) {
      final bridgeBotId = state.whoami?.bridgeBot;
      if (bridgeBotId == null || bridgeBotId.isEmpty) continue;
      bridgeBotIdsByProvider[state.provider] = bridgeBotId;
    }
    return BridgeProviderCatalog._(
      definitions: supportedProviders,
      bridgeBotIdsByProvider: bridgeBotIdsByProvider,
    );
  }
}

bool isOfficialBridgeBotUserId(
  String userId, {
  required String? ownHomeserverDomain,
}) {
  if (ownHomeserverDomain == null || userId.domain != ownHomeserverDomain) {
    return false;
  }
  return BridgeProviderCatalog.supportedProviders.values.any(
    (provider) => provider.matchesBridgeBotId(userId),
  );
}

class VisibleParticipantSummary {
  const VisibleParticipantSummary({
    required this.visibleUsers,
    required this.visibleCount,
  });

  final List<User> visibleUsers;
  final int visibleCount;
}

Iterable<User> visibleUsersWithoutOfficialBridgeBots(
  Iterable<User> users, {
  required String? ownHomeserverDomain,
}) => users.where(
  (user) => !isOfficialBridgeBotUserId(
    user.id,
    ownHomeserverDomain: ownHomeserverDomain,
  ),
);

List<User> visibleUsersWithoutOfficialBridgeBotsInRoom(
  Room room,
  Iterable<User> users,
) => visibleUsersWithoutOfficialBridgeBots(
  users,
  ownHomeserverDomain: room.client.userID?.domain,
).toList();

VisibleParticipantSummary summarizeVisibleParticipants(
  Room room,
  Iterable<User> participants,
) {
  final allParticipants = participants.toList();
  final visibleUsers = visibleUsersWithoutOfficialBridgeBotsInRoom(
    room,
    allParticipants,
  );
  final actualMembersCount =
      (room.summary.mInvitedMemberCount ?? 0) +
      (room.summary.mJoinedMemberCount ?? 0);
  final hiddenBridgeBotCount = allParticipants.length - visibleUsers.length;
  return VisibleParticipantSummary(
    visibleUsers: visibleUsers,
    visibleCount: math.max(
      visibleUsers.length,
      actualMembersCount - hiddenBridgeBotCount,
    ),
  );
}

class BridgeRoomPresentation {
  const BridgeRoomPresentation({
    this.provider,
    required this.isDirectLike,
    required this.shouldHideSenderPrefixes,
    this.primaryUserId,
    this.displayName,
    this.avatarUrl,
    this.loginId,
    this.loginName,
    this.loginNumber,
    this.showAccountLabel = false,
    this.showLoginNumberBadge = false,
  });

  final BridgeProviderDefinition? provider;
  final bool isDirectLike;
  final bool shouldHideSenderPrefixes;
  final String? primaryUserId;
  final String? displayName;
  final Uri? avatarUrl;
  final String? loginId;
  final String? loginName;
  final int? loginNumber;
  final bool showAccountLabel;
  final bool showLoginNumberBadge;

  bool get hasBridgeBadge => provider != null;

  factory BridgeRoomPresentation.fromRoom(
    Room room,
    BridgeProviderCatalog catalog, {
    MessieBridgeLoginInfo? roomMapping,
    int loginCountForProvider = 0,
    bool showLoginNumberBadge = false,
  }
  ) {
    final directChatMatrixId = room.directChatMatrixID;
    if (directChatMatrixId != null) {
      final provider = catalog.providerForRemoteUserId(directChatMatrixId);
      final directUser = room.unsafeGetUserFromMemoryOrFallback(
        directChatMatrixId,
      );
      return BridgeRoomPresentation(
        provider: provider,
        isDirectLike: true,
        shouldHideSenderPrefixes: true,
        primaryUserId: directChatMatrixId,
        displayName: directUser.calcDisplayname(),
        avatarUrl: directUser.avatarUrl,
        loginId: roomMapping?.loginId,
        loginName: roomMapping?.loginName,
        loginNumber: roomMapping?.loginNumber,
        showAccountLabel: provider != null && loginCountForProvider > 1,
        showLoginNumberBadge: provider != null && showLoginNumberBadge,
      );
    }

    final ownUserId = room.client.userID;
    final participants = {
      for (final user in room.getParticipants()) user.id: user,
    };
    if (ownUserId == null || participants.isEmpty) {
      return const BridgeRoomPresentation(
        isDirectLike: false,
        shouldHideSenderPrefixes: false,
      );
    }

    for (final entry in catalog.definitions.entries) {
      final provider = entry.value;
      final bridgeBotId = catalog.bridgeBotIdFor(entry.key);
      final remoteUsers = <User>[];
      var hasBridgeBot = false;
      var hasNonBridgeOthers = false;

      for (final user in participants.values) {
        if (user.id == ownUserId) continue;
        if (provider.matchesBridgeBotId(user.id, bridgeBotId: bridgeBotId)) {
          hasBridgeBot = true;
          continue;
        }
        if (provider.matchesRemoteUserId(user.id)) {
          remoteUsers.add(user);
          continue;
        }
        hasNonBridgeOthers = true;
      }

      if (remoteUsers.isEmpty) continue;

      // Only classify as a 1:1 "direct-like" chat if:
      // - There's exactly one remote user in memory
      // - No non-bridge others
      // - The room doesn't have an explicit name set (groups always have one)
      // - The actual member count matches what we see (not a partially-loaded group)
      final hasExplicitName = room.getState(EventTypes.RoomName)?.content
              .tryGet<String>('name')
              ?.isNotEmpty ==
          true;
      final actualMemberCount = room.summary.mJoinedMemberCount ?? 0;
      final looksLikeGroup = hasExplicitName || actualMemberCount > 3;

      if (hasBridgeBot &&
          remoteUsers.length == 1 &&
          !hasNonBridgeOthers &&
          !looksLikeGroup) {
        final remoteUser = remoteUsers.single;
        return BridgeRoomPresentation(
          provider: provider,
          isDirectLike: true,
          shouldHideSenderPrefixes: true,
          primaryUserId: remoteUser.id,
          displayName: remoteUser.calcDisplayname(),
          avatarUrl: remoteUser.avatarUrl,
          loginId: roomMapping?.loginId,
          loginName: roomMapping?.loginName,
          loginNumber: roomMapping?.loginNumber,
          showAccountLabel: loginCountForProvider > 1,
          showLoginNumberBadge: showLoginNumberBadge,
        );
      }

      return BridgeRoomPresentation(
        provider: provider,
        isDirectLike: false,
        shouldHideSenderPrefixes: false,
        loginId: roomMapping?.loginId,
        loginName: roomMapping?.loginName,
        loginNumber: roomMapping?.loginNumber,
        showAccountLabel: loginCountForProvider > 1,
        showLoginNumberBadge: showLoginNumberBadge,
      );
    }

    return const BridgeRoomPresentation(
      isDirectLike: false,
      shouldHideSenderPrefixes: false,
    );
  }
}
