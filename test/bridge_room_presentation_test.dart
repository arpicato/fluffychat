import 'package:fluffychat/services/bridge_room_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

class _FakeRoom extends Fake implements Room {
  _FakeRoom(this._directChatMatrixId);

  final String? _directChatMatrixId;

  @override
  String? get directChatMatrixID => _directChatMatrixId;
}

void main() {
  test('bridge bot is recognized for bridge direct chats', () {
    final catalog = BridgeProviderCatalog.fromStates([]);
    final room = _FakeRoom('@whatsapp_123456789:messie.arpinfidel.com');

    expect(
      catalog.isBridgeBotParticipantForDirectChat(
        '@whatsappbot:messie.arpinfidel.com',
        room,
      ),
      isTrue,
    );
  });

  test('non bridge participants are not treated as bridge bots', () {
    final catalog = BridgeProviderCatalog.fromStates([]);
    final room = _FakeRoom('@whatsapp_123456789:messie.arpinfidel.com');

    expect(
      catalog.isBridgeBotParticipantForDirectChat(
        '@realperson:messie.arpinfidel.com',
        room,
      ),
      isFalse,
    );
  });

  test('bridge bots are not filtered for non bridge direct chats', () {
    final catalog = BridgeProviderCatalog.fromStates([]);
    final room = _FakeRoom('@alice:messie.arpinfidel.com');

    expect(
      catalog.isBridgeBotParticipantForDirectChat(
        '@whatsappbot:messie.arpinfidel.com',
        room,
      ),
      isFalse,
    );
  });
}
