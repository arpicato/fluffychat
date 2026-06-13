import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/services/messie_error_service.dart';
import 'package:fluffychat/utils/custom_http_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendSession {
  BackendSession({
    required this.token,
    required this.mxid,
    required this.userId,
    required this.expiresAt,
  });

  final String token;
  final String mxid;
  final String userId;
  final int? expiresAt;

  Map<String, Object?> toJson() => {
    'token': token,
    'mxid': mxid,
    'userId': userId,
    'user_id': userId,
    'expiresAt': expiresAt,
  };

  factory BackendSession.fromJson(Map<String, Object?> json) => BackendSession(
    token: json['token'] as String,
    mxid: json['mxid'] as String? ?? '',
    userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
    expiresAt: json['expiresAt'] as int?,
  );
}

class BackendSessionService {
  static String get defaultApiBaseUrl {
    if (kIsWeb) return '/api/v1';
    final preset = AppSettings.presetHomeserver.value;
    if (preset.isEmpty) return '/api/v1';
    var uri = Uri.tryParse(preset);
    if (uri == null) return '/api/v1';
    if (uri.scheme.isEmpty) uri = Uri.https(preset, '');
    return '${uri.origin}/api/v1';
  }
  static const _sessionStoreKey = 'messie_backend_session';
  static const _refreshLeewayMs = 5 * 60 * 1000;

  BackendSessionService({http.Client? httpClient})
    : _httpClient = httpClient ?? CustomHttpClient.createHTTPClient();

  final http.Client _httpClient;
  final MessieErrorService _errorService = const MessieErrorService();

  Future<BackendSession> ensureSession(
    Client client,
    SharedPreferences store, {
    String? apiBaseUrl,
  }) async {
    apiBaseUrl ??= defaultApiBaseUrl;
    final userId = client.userID;
    if (userId == null || userId.isEmpty) {
      throw MessieUserException(
        kind: MessieErrorKind.unauthorized,
        operation: 'Backend session',
        userMessage: 'Your Matrix session is not active right now.',
      );
    }

    final cached = _readStoredSession(store);
    if (cached != null &&
        cached.mxid == userId &&
        cached.userId.isNotEmpty &&
        !_isExpiringSoon(cached)) {
      return cached;
    }

    try {
      final openId = await client.requestOpenIdToken(userId, const {});
      final response = await _httpClient
          .post(
            Uri.parse('$apiBaseUrl/auth/matrix/openid'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'access_token': openId.accessToken,
              'matrix_server_name': openId.matrixServerName,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        await MessieLogService.instance.write(
          'messie/session',
          'Backend auth failed',
          error:
              'status=${response.statusCode} body=${response.body.substring(0, response.body.length.clamp(0, 1000))}',
        );
        throw _errorService.httpFailure(
          'Backend session',
          response.statusCode,
          response.body,
        );
      }

      final json = jsonDecode(response.body) as Map<String, Object?>;
      final session = BackendSession(
        token: json['token'] as String,
        mxid: json['mxid'] as String? ?? userId,
        userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
        expiresAt: _decodeJwtExpiry(json['token'] as String),
      );
      await store.setString(_sessionStoreKey, jsonEncode(session.toJson()));
      return session;
    } on MessieUserException {
      rethrow;
    } on TimeoutException catch (error, stackTrace) {
      throw await _errorService.fromGeneric(
        'messie/session',
        'Backend session',
        error,
        stackTrace,
      );
    } on IOException catch (error, stackTrace) {
      throw await _errorService.fromGeneric(
        'messie/session',
        'Backend session',
        error,
        stackTrace,
      );
    } catch (error, stackTrace) {
      throw await _errorService.fromGeneric(
        'messie/session',
        'Backend session',
        error,
        stackTrace,
      );
    }
  }

  Future<void> clearSession(SharedPreferences store) =>
      store.remove(_sessionStoreKey);

  BackendSession? _readStoredSession(SharedPreferences store) {
    final raw = store.getString(_sessionStoreKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return BackendSession.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } catch (_) {
      return null;
    }
  }

  bool _isExpiringSoon(BackendSession session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return true;
    return expiresAt - DateTime.now().millisecondsSinceEpoch <=
        _refreshLeewayMs;
  }

  int? _decodeJwtExpiry(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final normalized = base64.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized)))
              as Map<String, Object?>;
      final exp = payload['exp'];
      if (exp is int) return exp * 1000;
      if (exp is num) return exp.toInt() * 1000;
    } catch (_) {
      return null;
    }
    return null;
  }
}
