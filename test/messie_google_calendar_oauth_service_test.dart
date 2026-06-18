import 'dart:convert';

import 'package:fluffychat/services/messie_google_calendar_oauth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('MessieGoogleCalendarOAuthService.startOAuthForToken', () {
    test('returns authorization URL on 200', () async {
      late http.Request capturedRequest;
      final mock = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'authorization_url': 'https://accounts.google.com/o/oauth2/auth?x=1',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = MessieGoogleCalendarOAuthService(httpClient: mock);
      final result = await service.startOAuthForToken(
        token: 'jwt-abc',
        apiBaseUrl: 'http://example.test/api/v1',
      );

      expect(
        result.authorizationUrl,
        'https://accounts.google.com/o/oauth2/auth?x=1',
      );
      expect(
        capturedRequest.url.toString(),
        'http://example.test/api/v1/calendar/google/oauth/start',
      );
      expect(capturedRequest.headers['Authorization'], 'Bearer jwt-abc');
    });

    test('throws on non-2xx response', () async {
      final mock = MockClient(
        (request) async => http.Response('boom', 500),
      );
      final service = MessieGoogleCalendarOAuthService(httpClient: mock);
      expect(
        () => service.startOAuthForToken(
          token: 'jwt',
          apiBaseUrl: 'http://example.test/api/v1',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when authorization_url is missing', () async {
      final mock = MockClient(
        (request) async =>
            http.Response(jsonEncode({'state': 'abc'}), 200),
      );
      final service = MessieGoogleCalendarOAuthService(httpClient: mock);
      expect(
        () => service.startOAuthForToken(
          token: 'jwt',
          apiBaseUrl: 'http://example.test/api/v1',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when authorization_url is empty', () async {
      final mock = MockClient(
        (request) async => http.Response(
          jsonEncode({'authorization_url': ''}),
          200,
        ),
      );
      final service = MessieGoogleCalendarOAuthService(httpClient: mock);
      expect(
        () => service.startOAuthForToken(
          token: 'jwt',
          apiBaseUrl: 'http://example.test/api/v1',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
