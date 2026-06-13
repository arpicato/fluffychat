import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluffychat/services/messie_error_service.dart';
import 'package:fluffychat/utils/custom_http_client.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend_session_service.dart';
import 'messie_workspace_refresh.dart';

enum MessieRealtimeEventType {
  workspaceRefresh,
  todoListCreated,
  todoListUpdated,
  todoListDeleted,
  todoListPinChanged,
  todoItemCreated,
  todoItemUpdated,
  todoItemDeleted,
  collaboratorAdded,
  collaboratorRemoved,
  unknown,
}

class MessieRealtimeEvent {
  const MessieRealtimeEvent({
    required this.id,
    required this.type,
    required this.userId,
    required this.data,
  });

  final String id;
  final MessieRealtimeEventType type;
  final String userId;
  final Map<String, Object?> data;

  String? get listId => data['list_id'] as String?;
  bool? get pinned => data['pinned'] as bool?;

  factory MessieRealtimeEvent.fromJson(Map<String, Object?> json) {
    final rawType = json['type'] as String? ?? '';
    return MessieRealtimeEvent(
      id: json['id'] as String? ?? '',
      type: switch (rawType) {
        'workspace.refresh' => MessieRealtimeEventType.workspaceRefresh,
        'todo_list.created' => MessieRealtimeEventType.todoListCreated,
        'todo_list.updated' => MessieRealtimeEventType.todoListUpdated,
        'todo_list.deleted' => MessieRealtimeEventType.todoListDeleted,
        'todo_list.pin_changed' => MessieRealtimeEventType.todoListPinChanged,
        'todo_item.created' => MessieRealtimeEventType.todoItemCreated,
        'todo_item.updated' => MessieRealtimeEventType.todoItemUpdated,
        'todo_item.deleted' => MessieRealtimeEventType.todoItemDeleted,
        'todo_list.collaborator_added' => MessieRealtimeEventType.collaboratorAdded,
        'todo_list.collaborator_removed' => MessieRealtimeEventType.collaboratorRemoved,
        _ => MessieRealtimeEventType.unknown,
      },
      userId: json['user_id'] as String? ?? '',
      data: (json['data'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }
}

class MessieRealtimeService {
  MessieRealtimeService._();

  static final MessieRealtimeService instance = MessieRealtimeService._();

  final BackendSessionService _sessionService = BackendSessionService();
  final http.Client _httpClient = CustomHttpClient.createHTTPClient();
  final MessieErrorService _errorService = const MessieErrorService();
  final StreamController<MessieRealtimeEvent> _eventsController =
      StreamController<MessieRealtimeEvent>.broadcast();

  Stream<MessieRealtimeEvent> get events => _eventsController.stream;

  Future<void>? _syncLoop;
  Timer? _reconnectTimer;
  bool _running = false;
  String? _activeMxid;
  int _since = 0;

  Future<void> start({
    required Client client,
    required SharedPreferences store,
    String? apiBaseUrl,
  }) async {
    final mxid = client.userID;
    if (mxid == null || mxid.isEmpty) return;
    apiBaseUrl ??= BackendSessionService.defaultApiBaseUrl;
    if (_running && _activeMxid == mxid) return;

    await stop();
    _running = true;
    _activeMxid = mxid;
    await _connect(client: client, store: store, apiBaseUrl: apiBaseUrl);
  }

  Future<void> stop() async {
    _running = false;
    _activeMxid = null;
    _since = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _syncLoop;
    _syncLoop = null;
  }

  Future<void> _connect({
    required Client client,
    required SharedPreferences store,
    required String apiBaseUrl,
  }) async {
    try {
      final session = await _sessionService.ensureSession(
        client,
        store,
        apiBaseUrl: apiBaseUrl,
      );
      _syncLoop = _runSyncLoop(
        client: client,
        store: store,
        apiBaseUrl: apiBaseUrl,
        jwt: session.token,
      );
      await _syncLoop;
    } catch (error, stackTrace) {
      await _errorService.fromGeneric(
        'messie/realtime',
        'Failed to start realtime sync',
        error,
        stackTrace,
      );
      _scheduleReconnect(client: client, store: store, apiBaseUrl: apiBaseUrl);
    }
  }

  Future<void> _runSyncLoop({
    required Client client,
    required SharedPreferences store,
    required String apiBaseUrl,
    required String jwt,
  }) async {
    while (_running && _activeMxid == client.userID) {
      try {
        final response = await _httpClient
            .get(
              Uri.parse('$apiBaseUrl/sync?since=$_since&timeout_ms=25000'),
              headers: {'Authorization': 'Bearer $jwt'},
            )
            .timeout(const Duration(seconds: 35));
        if (response.statusCode == 401) {
          await MessieLogService.instance.write(
            'messie/realtime',
            'Realtime sync unauthorized; clearing session',
          );
          await _sessionService.clearSession(store);
          _scheduleReconnect(client: client, store: store, apiBaseUrl: apiBaseUrl);
          return;
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          await MessieLogService.instance.write(
            'messie/realtime',
            'Realtime sync returned non-success status',
            error: 'status=${response.statusCode} body=${response.body.substring(0, response.body.length.clamp(0, 1000))}',
          );
          _scheduleReconnect(client: client, store: store, apiBaseUrl: apiBaseUrl);
          return;
        }

        final json = jsonDecode(response.body) as Map<String, Object?>;
        final nextBatch = json['next_batch'];
        if (nextBatch is int) {
          _since = nextBatch;
        } else if (nextBatch is num) {
          _since = nextBatch.toInt();
        }
        final rawEvents = (json['events'] as List?) ?? const [];
        for (final rawEvent in rawEvents) {
          final event = MessieRealtimeEvent.fromJson(
            (rawEvent as Map).cast<String, Object?>(),
          );
          _eventsController.add(event);
          _applyWorkspaceRefresh(event);
        }
      } on TimeoutException catch (error, stackTrace) {
        await _errorService.fromGeneric(
          'messie/realtime',
          'Realtime sync timed out',
          error,
          stackTrace,
        );
        _scheduleReconnect(client: client, store: store, apiBaseUrl: apiBaseUrl);
        return;
      } on IOException catch (error, stackTrace) {
        await _errorService.fromGeneric(
          'messie/realtime',
          'Realtime sync lost network connectivity',
          error,
          stackTrace,
        );
        _scheduleReconnect(client: client, store: store, apiBaseUrl: apiBaseUrl);
        return;
      } catch (error, stackTrace) {
        await _errorService.fromGeneric(
          'messie/realtime',
          'Realtime sync failed',
          error,
          stackTrace,
        );
        _scheduleReconnect(client: client, store: store, apiBaseUrl: apiBaseUrl);
        return;
      }
    }
  }

  void _applyWorkspaceRefresh(MessieRealtimeEvent event) {
    switch (event.type) {
      case MessieRealtimeEventType.todoListCreated:
      case MessieRealtimeEventType.todoListUpdated:
      case MessieRealtimeEventType.todoListDeleted:
      case MessieRealtimeEventType.todoListPinChanged:
      case MessieRealtimeEventType.collaboratorAdded:
      case MessieRealtimeEventType.collaboratorRemoved:
        MessieWorkspaceRefresh.instance.bump(
          MessieWorkspaceRefreshSignal(
            kind: MessieWorkspaceRefreshKind.todoLists,
            listId: event.listId,
          ),
        );
        break;
      case MessieRealtimeEventType.todoItemCreated:
      case MessieRealtimeEventType.todoItemUpdated:
      case MessieRealtimeEventType.todoItemDeleted:
        MessieWorkspaceRefresh.instance.bump(
          MessieWorkspaceRefreshSignal(
            kind: MessieWorkspaceRefreshKind.todoItems,
            listId: event.listId,
          ),
        );
        break;
      case MessieRealtimeEventType.workspaceRefresh:
      case MessieRealtimeEventType.unknown:
        MessieWorkspaceRefresh.instance.bump();
        break;
    }
  }

  void _scheduleReconnect({
    required Client client,
    required SharedPreferences store,
    required String apiBaseUrl,
  }) {
    if (!_running) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _connect(client: client, store: store, apiBaseUrl: apiBaseUrl);
    });
  }
}
