import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
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

  factory MessieBridgeProvisioningStep.fromApi(api.BridgeLoginStep step) {
    final value = step.oneOf.value;

    if (value is api.LoginStepDisplayAndWait) {
      return MessieBridgeProvisioningStep(
        type: 'display_and_wait',
        processId: value.processId,
        stepId: value.stepId,
        loginId: value.loginId,
        message: value.displayAndWait.message,
        data: value.displayAndWait.data,
        imageUrl: value.displayAndWait.imageUrl,
      );
    }

    if (value is api.LoginStepUserInput) {
      return MessieBridgeProvisioningStep(
        type: 'user_input',
        processId: value.processId,
        stepId: value.stepId,
        loginId: value.loginId,
        fields: value.userInput.fields
                ?.map(
                  (field) => MessieBridgeInputField(
                    id: field.id ?? '',
                    label: field.label,
                    kind: field.kind,
                    secret: field.secret ?? false,
                  ),
                )
                .where((field) => field.id.isNotEmpty)
                .toList() ??
            const [],
      );
    }

    if (value is api.LoginStepCookies) {
      return MessieBridgeProvisioningStep(
        type: 'cookies',
        processId: value.processId,
        stepId: value.stepId,
        loginId: value.loginId,
      );
    }

    if (value is api.LoginStepComplete) {
      return MessieBridgeProvisioningStep(
        type: 'complete',
        processId: value.processId,
        stepId: value.stepId,
        loginId: value.loginId,
        userLoginId: value.complete.userLoginId,
      );
    }

    throw StateError('Unsupported bridge login step variant: ${value.runtimeType}');
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
      final response = await apiClient.defaultApi.bridgeStartLogin(
        flow: flow,
        provider: provider,
      );
      final step = response.data;
      if (step == null) {
        throw StateError('Bridge start login returned no step.');
      }
      return MessieBridgeProvisioningStep.fromApi(step);
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
      final requestBody = BuiltMap<String, JsonObject>(
        body.map((key, value) => MapEntry(key, JsonObject(value))),
      );
      final response = await apiClient.defaultApi.bridgeSubmitLoginStep(
        processId: processId,
        stepId: stepId,
        action: action,
        provider: provider,
        requestBody: requestBody,
      );
      final step = response.data;
      if (step == null) {
        throw StateError('Bridge submit step returned no step.');
      }
      return MessieBridgeProvisioningStep.fromApi(step);
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
    return _MessieBridgeApiClient(
      sdk: sdk,
      defaultApi: sdk.getDefaultApi(),
    );
  }
}

class _MessieBridgeApiClient {
  _MessieBridgeApiClient({required this.sdk, required this.defaultApi});

  final api.MessieApi sdk;
  final api.DefaultApi defaultApi;

  void dispose() => sdk.dio.close(force: true);
}
