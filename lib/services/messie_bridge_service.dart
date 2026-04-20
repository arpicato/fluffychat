import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluffychat/services/backend_session_service.dart';
import 'package:matrix/matrix.dart';
import 'package:messie_api/messie_api.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';

String _normalizeMessieBridgeApiBaseUrl(String value) =>
    value.endsWith('/') ? value : '$value/';

class MessieBridgeState {
  MessieBridgeState({
    required this.provider,
    required this.connections,
    required this.whoami,
    required this.flows,
  });

  final String provider;
  final List<api.BridgeConnection> connections;
  final api.BridgeWhoamiResponse? whoami;
  final List<api.BridgeLoginFlow> flows;

  api.BridgeConnection? get connection {
    for (final connection in connections) {
      if (connection.provider == provider) return connection;
    }
    return null;
  }

  List<api.BridgeWhoamiLogin> get logins => whoami?.logins?.toList() ?? const [];
}

class MessieBridgeInputField {
  MessieBridgeInputField({
    required this.id,
    required this.label,
    required this.kind,
    required this.secret,
  });

  final String id;
  final String? label;
  final String? kind;
  final bool secret;
}

class MessieBridgeProvisioningStep {
  MessieBridgeProvisioningStep({
    required this.type,
    this.processId,
    this.stepId,
    this.loginId,
    this.message,
    this.instructions,
    this.data,
    this.dataType,
    this.imageUrl,
    this.fields = const [],
    this.userLoginId,
  });

  final String type;
  final String? processId;
  final String? stepId;
  final String? loginId;
  final String? message;
  final String? instructions;
  final String? data;
  final String? dataType;
  final String? imageUrl;
  final List<MessieBridgeInputField> fields;
  final String? userLoginId;

  String? get effectiveProcessId => processId ?? loginId;
  bool get isCodeDisplay {
    if (dataType == 'code') return true;
    final value = data;
    if (value == null) return false;
    return RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(value.trim());
  }

  bool get isDisplayAndWait => type == 'display_and_wait';
  bool get isUserInput => type == 'user_input';
  bool get isCookies => type == 'cookies';
  bool get isComplete => type == 'complete';

  factory MessieBridgeProvisioningStep.fromJson(Map<String, Object?> json) {
    final type = json['type'] as String? ?? 'display_and_wait';
    final displayAndWait =
        json['display_and_wait'] as Map<Object?, Object?>? ?? const {};
    final userInput = json['user_input'] as Map<Object?, Object?>? ?? const {};
    final complete = json['complete'] as Map<Object?, Object?>? ?? const {};
    final rawFields = userInput['fields'] as List<Object?>? ?? const [];

    return MessieBridgeProvisioningStep(
      type: type,
      processId: json['process_id'] as String?,
      stepId: json['step_id'] as String?,
      loginId: json['login_id'] as String?,
      message: displayAndWait['message'] as String?,
      instructions: json['instructions'] as String?,
      data: displayAndWait['data'] as String?,
      dataType: displayAndWait['type'] as String?,
      imageUrl: displayAndWait['image_url'] as String?,
      fields: rawFields
          .whereType<Map<Object?, Object?>>()
          .map(
            (field) => MessieBridgeInputField(
              id: field['id'] as String? ?? '',
              label: field['label'] as String?,
              kind: field['kind'] as String?,
              secret: field['secret'] as bool? ?? false,
            ),
          )
          .where((field) => field.id.isNotEmpty)
          .toList(),
      userLoginId: complete['user_login_id'] as String?,
    );
  }
}

class MessieBridgeService {
  MessieBridgeService({
    BackendSessionService? sessionService,
    this.apiBaseUrl = BackendSessionService.defaultApiBaseUrl,
  }) : _sessionService = sessionService ?? BackendSessionService();

  final BackendSessionService _sessionService;
  final String apiBaseUrl;

  Future<MessieBridgeState> loadState(
    Client client, {
    String provider = 'whatsapp',
  }) async {
    final apiClient = await _createApiClient(client);
    try {
      final connectionsResponse = await apiClient.defaultApi.getConnections();
      final whoamiResponse = await apiClient.defaultApi.bridgeWhoami(
        provider: provider,
      );
      final flows =
          whoamiResponse.data?.loginFlows?.toList() ??
          (await apiClient.defaultApi.bridgeGetLoginFlows(provider: provider)).data
                  ?.flows
                  ?.toList() ??
          const <api.BridgeLoginFlow>[];
      return MessieBridgeState(
        provider: provider,
        connections: connectionsResponse.data?.toList() ?? const [],
        whoami: whoamiResponse.data,
        flows: flows,
      );
    } finally {
      apiClient.dispose();
    }
  }

  Future<MessieBridgeProvisioningStep> startLogin(
    Client client, {
    required String provider,
    required String flow,
  }) async {
    final apiClient = await _createApiClient(client);
    try {
      final response = await apiClient.dio.post<Map<String, dynamic>>(
        'bridge/provision/v3/login/start/$flow',
        queryParameters: {'provider': provider},
      );
      return MessieBridgeProvisioningStep.fromJson(
        _normalizeJsonMap(response.data),
      );
    } finally {
      apiClient.dispose();
    }
  }

  Future<MessieBridgeProvisioningStep> submitStep(
    Client client, {
    required String provider,
    required String processId,
    required String stepId,
    required String action,
    Map<String, Object?> body = const {},
  }) async {
    final apiClient = await _createApiClient(client);
    try {
      final response = await apiClient.dio.post<Map<String, dynamic>>(
        'bridge/provision/v3/login/step/$processId/$stepId/$action',
        queryParameters: {'provider': provider},
        data: body,
      );
      return MessieBridgeProvisioningStep.fromJson(
        _normalizeJsonMap(response.data),
      );
    } finally {
      apiClient.dispose();
    }
  }

  Future<void> logout(
    Client client, {
    required String provider,
    String loginId = 'all',
  }) async {
    final apiClient = await _createApiClient(client);
    try {
      await apiClient.defaultApi.bridgeLogout(
        loginId: loginId,
        provider: provider,
      );
    } finally {
      apiClient.dispose();
    }
  }

  Future<_MessieBridgeApiClient> _createApiClient(Client client) async {
    final store = await SharedPreferences.getInstance();
    final session = await _sessionService.ensureSession(
      client,
      store,
      apiBaseUrl: apiBaseUrl,
    );
    final normalizedBaseUrl = _normalizeMessieBridgeApiBaseUrl(apiBaseUrl);
    final sdk = api.MessieApi(basePathOverride: normalizedBaseUrl);
    sdk.setBearerAuth('bearerAuth', session.token);
    final dio = Dio(
      BaseOptions(
        baseUrl: normalizedBaseUrl,
        headers: {
          'Authorization': 'Bearer ${session.token}',
          'Content-Type': 'application/json',
        },
      ),
    );
    return _MessieBridgeApiClient(
      dio: dio,
      defaultApi: sdk.getDefaultApi(),
    );
  }
}

Map<String, Object?> _normalizeJsonMap(Object? json) {
  if (json is Map<String, dynamic>) {
    return json.map((key, value) => MapEntry(key, _normalizeJsonValue(value)));
  }
  if (json is Map<Object?, Object?>) {
    return json.map(
      (key, value) => MapEntry(key.toString(), _normalizeJsonValue(value)),
    );
  }
  if (json is String && json.isNotEmpty) {
    final decoded = jsonDecode(json);
    return _normalizeJsonMap(decoded);
  }
  return const {};
}

Object? _normalizeJsonValue(Object? value) {
  if (value is Map<Object?, Object?> || value is Map<String, dynamic>) {
    return _normalizeJsonMap(value);
  }
  if (value is List) {
    return value.map(_normalizeJsonValue).toList();
  }
  return value;
}

class _MessieBridgeApiClient {
  _MessieBridgeApiClient({required this.dio, required this.defaultApi});

  final Dio dio;
  final api.DefaultApi defaultApi;

  void dispose() => dio.close(force: true);
}
