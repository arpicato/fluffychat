import 'package:fluffychat/services/bridge_room_presentation.dart';
import 'package:fluffychat/services/messie_bridge_service.dart';
import 'package:matrix/matrix.dart';

class LoadedMessieBridgeCatalog {
  const LoadedMessieBridgeCatalog({
    required this.catalog,
    required this.logins,
  });

  final BridgeProviderCatalog catalog;
  final List<MessieBridgeLoginInfo> logins;
}

class MessieBridgeCatalogLoader {
  MessieBridgeCatalogLoader({
    MessieBridgeService? bridgeService,
  }) : _bridgeService = bridgeService ?? MessieBridgeService();

  final MessieBridgeService _bridgeService;

  Future<LoadedMessieBridgeCatalog> load(Client client) async {
    final stopwatch = Stopwatch()..start();
    Logs().d('[messie/bridge] start load provider catalog');
    final states = await Future.wait(
      BridgeProviderCatalog.supportedProviders.keys.map(
        (provider) => _bridgeService.loadState(client, provider: provider),
      ),
    );

    final loginNumbersByProvider = <String, Map<String, int>>{};
    for (final state in states) {
      final numbers = <String, int>{};
      for (var i = 0; i < state.logins.length; i++) {
        numbers[state.logins[i].id] = i + 1;
      }
      loginNumbersByProvider[state.provider] = numbers;
    }

    final result = LoadedMessieBridgeCatalog(
      catalog: BridgeProviderCatalog.fromStates(states),
      logins: [
        for (final state in states)
          ...state.logins.map(
            (login) => MessieBridgeLoginInfo.fromWhoamiLogin(
              state.provider,
              login,
              loginNumbersByProvider[state.provider]?[login.id] ?? 1,
            ),
          ),
        ],
    );
    Logs().d(
      '[messie/bridge] ok load provider catalog elapsed=${stopwatch.elapsedMilliseconds}ms',
    );
    return result;
  }
}
