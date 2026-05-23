// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/config/setting_keys.dart';
import 'package:matrix/matrix.dart';

bool shouldSuppressMessieNotification(Event event) {
  if (_isBridgeBackfillNotification(event)) return true;
  if (_isBridgeBotInvite(event)) return true;
  return false;
}

void migrateMessieHomeserverUrls(Iterable<Client> clients) {
  final preset = AppSettings.presetHomeserver.value;
  if (preset.isEmpty) return;

  var targetHomeserver = Uri.tryParse(preset);
  if (targetHomeserver == null) return;
  if (targetHomeserver.scheme.isEmpty) {
    targetHomeserver = Uri.https(preset, '');
  }

  for (final c in clients) {
    if (!c.isLogged()) continue;
    final current = c.homeserver;
    if (current == null) continue;
    if (current.host == targetHomeserver.host &&
        current.scheme == targetHomeserver.scheme) {
      continue;
    }
    Logs().i(
      '[HomeserverMigration] Updating ${c.clientName} from $current to $targetHomeserver',
    );
    c.homeserver = targetHomeserver;
  }
}

const _bridgeSenderPrefixes = [
  '@whatsapp_',
  '@telegram_',
  '@signal_',
  '@discord_',
  '@instagram_',
];

const _bridgeBotLocalparts = [
  'whatsappbot',
  'telegrambot',
  'signalbot',
  'discordbot',
  'instagrambot',
];

bool _isBridgeBot(String senderId) {
  final localpart = senderId.split(':').first;
  return _bridgeBotLocalparts.any((b) => localpart == '@$b');
}

bool _isBridgeBackfillNotification(Event event) {
  final room = event.room;
  if (room.highlightCount > 0) return false;

  final createEvent = room.getState(EventTypes.RoomCreate);
  if (createEvent is MatrixEvent) {
    if (createEvent.originServerTs.isAfter(event.originServerTs)) {
      return true;
    }
  }

  return false;
}

bool _isBridgeBotInvite(Event event) {
  return event.type == EventTypes.RoomMember && _isBridgeBot(event.senderId);
}
