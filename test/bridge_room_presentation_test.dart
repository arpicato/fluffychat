import 'package:fluffychat/services/bridge_room_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

class _FakeRoom extends Fake implements Room {
  _FakeRoom({String? directChatMatrixId})
    : _directChatMatrixId = directChatMatrixId;

  final String? _directChatMatrixId;

  @override
  String? get directChatMatrixID => _directChatMatrixId;
}

void main() {
  test('whatsapp direct chat resolves whatsapp provider', () {
    final catalog = BridgeProviderCatalog.fromStates([]);
    final room = _FakeRoom(
      directChatMatrixId: '@whatsapp_123456789:messie.arpinfidel.com',
    );

    expect(catalog.providerForRemoteUserId(room.directChatMatrixID!), isNotNull);
    expect(
      catalog
          .providerForRemoteUserId(room.directChatMatrixID!)
          ?.matchesBridgeBotId('@whatsappbot:messie.arpinfidel.com'),
      isTrue,
    );
  });

  test('bridge-like user id does not match non-bot participant', () {
    final catalog = BridgeProviderCatalog.fromStates([]);
    final room = _FakeRoom(
      directChatMatrixId: '@whatsapp_123456789:messie.arpinfidel.com',
    );

    expect(
      catalog
          .providerForRemoteUserId(room.directChatMatrixID!)
          ?.matchesBridgeBotId('@realperson:messie.arpinfidel.com'),
      isFalse,
    );
  });

  test('non-bridge direct chats do not resolve a bridge provider', () {
    final catalog = BridgeProviderCatalog.fromStates([]);
    final room = _FakeRoom(directChatMatrixId: '@alice:messie.arpinfidel.com');

    expect(catalog.providerForRemoteUserId(room.directChatMatrixID!), isNull);
  });
}
