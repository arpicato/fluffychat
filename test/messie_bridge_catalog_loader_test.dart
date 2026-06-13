import 'package:fluffychat/services/messie_bridge_catalog_loader.dart';
import 'package:fluffychat/services/messie_bridge_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:messie_api/messie_api.dart' as api;

class _FakeClient extends Fake implements Client {}

class _FakeBridgeService extends Fake implements MessieBridgeService {
  final Map<String, Object> responsesByProvider;

  _FakeBridgeService(this.responsesByProvider);

  @override
  Future<MessieBridgeState> loadState(
    Client client, {
    String provider = 'whatsapp',
  }) async {
    final response = responsesByProvider[provider];
    if (response is MessieBridgeState) return response;
    if (response is Exception) throw response;
    throw StateError('No stubbed response for provider $provider');
  }
}

void main() {
  test('bridge catalog loader keeps successful providers when one fails', () async {
    final loader = MessieBridgeCatalogLoader(
      bridgeService: _FakeBridgeService({
        'whatsapp': MessieBridgeState(
          provider: 'whatsapp',
          connections: const [],
          whoami: api.BridgeWhoamiResponse(
            (b) => b.bridgeBot = '@whatsappbot:messie.arpinfidel.com',
          ),
          flows: const [],
        ),
        'telegram': Exception('provider down'),
      }),
      providers: const ['whatsapp', 'telegram'],
    );

    final result = await loader.load(_FakeClient());

    expect(
      result.catalog.bridgeBotIdFor('whatsapp'),
      '@whatsappbot:messie.arpinfidel.com',
    );
    expect(result.logins, isEmpty);
  });
}
