import 'dart:async';
import 'dart:convert';

import 'package:fluffychat/services/backend_session_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher_string.dart';

class MessieGoogleCalendarOAuthResult {
  const MessieGoogleCalendarOAuthResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class MessieGoogleCalendarOAuthStart {
  const MessieGoogleCalendarOAuthStart({required this.authorizationUrl});

  final String authorizationUrl;
}

class MessieGoogleCalendarOAuthService {
  MessieGoogleCalendarOAuthService({
    BackendSessionService? sessionService,
    http.Client? httpClient,
  }) : _sessionService = sessionService ?? BackendSessionService(),
       _httpClient = httpClient ?? http.Client();

  final BackendSessionService _sessionService;
  final http.Client _httpClient;

  /// Pure HTTP step: ask the backend for an authorization URL.
  /// Visible for testing — does not perform any browser navigation.
  @visibleForTesting
  Future<MessieGoogleCalendarOAuthStart> startOAuthForToken({
    required String token,
    String? apiBaseUrl,
  }) async {
    final baseUrl = apiBaseUrl ?? BackendSessionService.defaultApiBaseUrl;
    final uri = Uri.parse('$baseUrl/calendar/google/oauth/start');
    final response = await _httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to start Google Calendar OAuth: ${response.statusCode} ${response.body}',
      );
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final authorizationUrl = payload['authorization_url']?.toString();
    if (authorizationUrl == null || authorizationUrl.isEmpty) {
      throw Exception(
        'Google Calendar OAuth start response missing authorization_url.',
      );
    }
    return MessieGoogleCalendarOAuthStart(authorizationUrl: authorizationUrl);
  }

  Future<MessieGoogleCalendarOAuthResult> connect(
    Client client,
    SharedPreferences store,
  ) async {
    final session = await _sessionService.ensureSession(client, store);
    final start = await startOAuthForToken(token: session.token);
    final authorizationUrl = start.authorizationUrl;

    if (kIsWeb) {
      final future = html.window.onMessage
          .firstWhere(
            (event) =>
                event.data is Map &&
                event.data['source'] == 'messie-google-calendar-oauth',
          )
          .timeout(const Duration(minutes: 5));
      await launchUrlString(
        authorizationUrl,
        webOnlyWindowName: 'messie-google-calendar-oauth',
      );
      final event = await future;
      final data = event.data as Map;
      return MessieGoogleCalendarOAuthResult(
        success: data['status'] == 'success',
        message:
            data['message']?.toString() ?? 'Google Calendar flow finished.',
      );
    }

    await launchUrlString(
      authorizationUrl,
      mode: LaunchMode.externalApplication,
    );
    return const MessieGoogleCalendarOAuthResult(
      success: true,
      message: 'Finish Google sign-in in browser, then refresh calendar list.',
    );
  }
}
