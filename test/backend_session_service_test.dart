import 'package:fluffychat/services/backend_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendSession', () {
    test('parses backend user id from snake_case payloads', () {
      final session = BackendSession.fromJson({
        'token': 'test-token',
        'mxid': '@alice:messie.localhost',
        'user_id': '7abe04b7-9ae8-454a-b89f-4a3f53b7a8b9',
      });

      expect(session.userId, '7abe04b7-9ae8-454a-b89f-4a3f53b7a8b9');
    });

    test('parses backend user id from camelCase payloads', () {
      final session = BackendSession.fromJson({
        'token': 'test-token',
        'mxid': '@alice:messie.localhost',
        'userId': '7abe04b7-9ae8-454a-b89f-4a3f53b7a8b9',
      });

      expect(session.userId, '7abe04b7-9ae8-454a-b89f-4a3f53b7a8b9');
    });

    test('serializes user id in both formats for compatibility', () {
      final session = BackendSession(
        token: 'test-token',
        mxid: '@alice:messie.localhost',
        userId: '7abe04b7-9ae8-454a-b89f-4a3f53b7a8b9',
        expiresAt: 1234567890,
      );

      final json = session.toJson();

      expect(json['userId'], '7abe04b7-9ae8-454a-b89f-4a3f53b7a8b9');
      expect(json['user_id'], '7abe04b7-9ae8-454a-b89f-4a3f53b7a8b9');
    });

    test('retains mxid for cache validation across account switches', () {
      final session = BackendSession.fromJson({
        'token': 'test-token',
        'mxid': '@alice:messie.localhost',
        'user_id': '7abe04b7-9ae8-454a-b89f-4a3f53b7a8b9',
      });

      expect(session.mxid, '@alice:messie.localhost');
    });
  });
}
