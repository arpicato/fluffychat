import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../../services/backend_session_service.dart';
import '../../services/messie_calendar_service.dart';
import '../../services/messie_realtime_service.dart';
import '../../services/messie_workspace_snapshot_service.dart';
import '../../services/messie_todo_service.dart';
import '../../services/messie_workspace_refresh.dart';
import '../../widgets/matrix.dart';

/// Mixin that provides workspace data (todos + calendar) to the chat list
/// controller. Keeps Messie-specific logic isolated from upstream FluffyChat
/// code to reduce merge conflicts.
mixin ChatListWorkspaceMixin<T extends StatefulWidget> on State<T> {
  final BackendSessionService _backendSessionService = BackendSessionService();
  final MessieCalendarService _messieCalendarService = MessieCalendarService();
  final MessieTodoService _messieTodoService = MessieTodoService();
  final MessieWorkspaceSnapshotService _workspaceSnapshotService =
      const MessieWorkspaceSnapshotService();
  static const Duration workspaceHydrationTimeout = Duration(milliseconds: 75);

  @protected
  BackendSessionService get backendSessionService => _backendSessionService;

  @protected
  MessieCalendarService get messieCalendarService => _messieCalendarService;

  @protected
  MessieTodoService get messieTodoService => _messieTodoService;

  @protected
  MessieWorkspaceSnapshotService get workspaceSnapshotService =>
      _workspaceSnapshotService;

  @protected
  Future<BackendSession> ensureBackendSession(MatrixState matrix) =>
      backendSessionService.ensureSession(matrix.client, matrix.store);

  @protected
  String get backendApiBaseUrl => BackendSessionService.defaultApiBaseUrl;

  @protected
  bool get enableMessieRealtime => true;

  List<MessieTodoList> todoLists = const [];
  bool isLoadingTodoLists = false;
  Object? todoListsError;
  final Map<String, MessieTodoList> _optimisticTodoListsById = {};
  List<MessieCalendarEvent> upcomingCalendarEvents = const [];
  bool isLoadingCalendarEvents = false;
  Object? calendarEventsError;
  bool isWorkspaceSnapshotHydrated = false;
  bool isWorkspaceReadyForFirstPaint = false;
  Timer? _workspaceFirstPaintTimer;

  Future<void> refreshTodoLists() async {
    if (isLoadingTodoLists || !mounted) return;

    setState(() {
      isLoadingTodoLists = true;
      todoListsError = null;
    });

    try {
      final matrix = Matrix.of(context);
      final session = await ensureBackendSession(matrix);
      final todoLists = await messieTodoService.getTodoLists(
        apiBaseUrl: backendApiBaseUrl,
        jwt: session.token,
        userId: session.userId,
      );
      if (!mounted) return;
      final mergedTodoLists = [
        ...todoLists,
        ..._optimisticTodoListsById.values.where(
          (optimistic) => todoLists.every((list) => list.id != optimistic.id),
        ),
      ];
      setState(() {
        this.todoLists = mergedTodoLists;
        isLoadingTodoLists = false;
      });
      await persistWorkspaceSnapshot();
    } catch (error, stackTrace) {
      Logs().w('Unable to load Messie todo lists', error, stackTrace);
      if (!mounted) return;
      setState(() {
        isLoadingTodoLists = false;
        todoListsError = error;
      });
    }
  }

  void addTodoListToWorkspace(MessieTodoList todoList) {
    if (!mounted) return;
    setState(() {
      _optimisticTodoListsById[todoList.id] = todoList;
      todoLists = [todoList, ...todoLists.where((list) => list.id != todoList.id)];
      todoListsError = null;
    });
    unawaited(persistWorkspaceSnapshot());
  }

  void removeTodoListFromWorkspace(String todoListId) {
    if (!mounted) return;
    setState(() {
      _optimisticTodoListsById.remove(todoListId);
      todoLists = todoLists.where((list) => list.id != todoListId).toList();
      todoListsError = null;
    });
    unawaited(persistWorkspaceSnapshot());
  }

  bool isTodoListPinned(String todoListId) =>
      todoLists.any((list) => list.id == todoListId && list.pinned);

  Future<void> setTodoListPinned(String todoListId, bool pinned) async {
    final matrix = Matrix.of(context);
    final session = await ensureBackendSession(matrix);
    final updatedTodoList = await messieTodoService.setTodoListPin(
      apiBaseUrl: backendApiBaseUrl,
      jwt: session.token,
      listId: todoListId,
      pinned: pinned,
    );
    if (!mounted) return;
    setState(() {
      todoLists = todoLists
          .map((list) => list.id == todoListId ? updatedTodoList : list)
          .toList();
    });
    await persistWorkspaceSnapshot();
  }

  Future<void> refreshCalendarEvents() async {
    if (isLoadingCalendarEvents || !mounted) return;

    setState(() {
      isLoadingCalendarEvents = true;
      calendarEventsError = null;
    });

    try {
      final matrix = Matrix.of(context);
      final session = await ensureBackendSession(matrix);
      final events = await messieCalendarService.getUpcomingCalendarEvents(
        apiBaseUrl: backendApiBaseUrl,
        jwt: session.token,
        limit: 25,
      );
      if (!mounted) return;
      setState(() {
        upcomingCalendarEvents = events;
        isLoadingCalendarEvents = false;
      });
      await persistWorkspaceSnapshot();
    } catch (error, stackTrace) {
      Logs().w('Unable to load Messie calendar events', error, stackTrace);
      if (!mounted) return;
      setState(() {
        isLoadingCalendarEvents = false;
        calendarEventsError = error;
      });
    }
  }

  Future<void> refreshWorkspaceData() async {
    final signal = MessieWorkspaceRefresh.instance.signal;
    switch (signal.kind) {
      case MessieWorkspaceRefreshKind.full:
        await Future.wait([refreshTodoLists(), refreshCalendarEvents()]);
        break;
      case MessieWorkspaceRefreshKind.todoLists:
        await refreshTodoLists();
        break;
      case MessieWorkspaceRefreshKind.todoItems:
        await refreshTodoLists();
        break;
      case MessieWorkspaceRefreshKind.calendar:
        await refreshCalendarEvents();
        break;
    }
  }

  void initWorkspace() {
    MessieWorkspaceRefresh.instance.addListener(refreshWorkspaceData);
    _workspaceFirstPaintTimer = Timer(
      workspaceHydrationTimeout,
      _markWorkspaceReadyForFirstPaint,
    );
    unawaited(_hydrateWorkspaceSnapshot());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refreshWorkspaceData();
      if (!mounted || !enableMessieRealtime) return;
      final matrix = Matrix.of(context);
      await MessieRealtimeService.instance.start(
        client: matrix.client,
        store: matrix.store,
        apiBaseUrl: backendApiBaseUrl,
      );
    });
  }

  void disposeWorkspace() {
    MessieWorkspaceRefresh.instance.removeListener(refreshWorkspaceData);
    _workspaceFirstPaintTimer?.cancel();
    MessieRealtimeService.instance.stop();
  }

  @protected
  Future<void> persistWorkspaceSnapshot() async {
    if (!mounted) return;
    final matrix = Matrix.of(context);
    final userKey = _workspaceSnapshotUserKey(matrix.client);
    if (userKey == null) return;
    await workspaceSnapshotService.write(
      store: matrix.store,
      userKey: userKey,
      snapshot: MessieWorkspaceSnapshot(
        savedAt: DateTime.now().toUtc(),
        todoLists: todoLists,
        upcomingCalendarEvents: upcomingCalendarEvents,
      ),
    );
  }

  Future<void> _hydrateWorkspaceSnapshot() async {
    if (!mounted) return;
    final matrix = Matrix.of(context);
    final userKey = _workspaceSnapshotUserKey(matrix.client);
    if (userKey == null) {
      _markWorkspaceSnapshotHydrated();
      return;
    }
    final snapshot = await workspaceSnapshotService.read(
      store: matrix.store,
      userKey: userKey,
    );
    if (!mounted) return;
    if (snapshot != null) {
      setState(() {
        todoLists = [
          ...snapshot.todoLists,
          ..._optimisticTodoListsById.values.where(
            (optimistic) =>
                snapshot.todoLists.every((list) => list.id != optimistic.id),
          ),
        ];
        upcomingCalendarEvents = snapshot.upcomingCalendarEvents;
      });
    }
    _markWorkspaceSnapshotHydrated();
    _markWorkspaceReadyForFirstPaint();
  }

  void _markWorkspaceReadyForFirstPaint() {
    if (!mounted || isWorkspaceReadyForFirstPaint) return;
    _workspaceFirstPaintTimer?.cancel();
    _workspaceFirstPaintTimer = null;
    setState(() {
      isWorkspaceReadyForFirstPaint = true;
    });
  }

  void _markWorkspaceSnapshotHydrated() {
    if (!mounted || isWorkspaceSnapshotHydrated) return;
    setState(() {
      isWorkspaceSnapshotHydrated = true;
    });
  }

  String? _workspaceSnapshotUserKey(Client client) {
    final userId = client.userID;
    if (userId == null || userId.isEmpty) return null;
    return userId;
  }
}
