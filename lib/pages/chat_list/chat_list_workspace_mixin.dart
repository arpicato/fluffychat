import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../../services/backend_session_service.dart';
import '../../services/messie_calendar_service.dart';
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

  @protected
  BackendSessionService get backendSessionService => _backendSessionService;

  @protected
  MessieCalendarService get messieCalendarService => _messieCalendarService;

  @protected
  MessieTodoService get messieTodoService => _messieTodoService;

  @protected
  Future<BackendSession> ensureBackendSession(MatrixState matrix) =>
      backendSessionService.ensureSession(matrix.client, matrix.store);

  @protected
  String get backendApiBaseUrl => BackendSessionService.defaultApiBaseUrl;

  List<MessieTodoList> todoLists = const [];
  bool isLoadingTodoLists = false;
  Object? todoListsError;
  final Map<String, MessieTodoList> _optimisticTodoListsById = {};
  List<MessieCalendarEvent> upcomingCalendarEvents = const [];
  bool isLoadingCalendarEvents = false;
  Object? calendarEventsError;

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
  }

  void removeTodoListFromWorkspace(String todoListId) {
    if (!mounted) return;
    setState(() {
      _optimisticTodoListsById.remove(todoListId);
      todoLists = todoLists.where((list) => list.id != todoListId).toList();
      todoListsError = null;
    });
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
    await Future.wait([
      refreshTodoLists(),
      refreshCalendarEvents(),
    ]);
  }

  void initWorkspace() {
    MessieWorkspaceRefresh.instance.addListener(refreshWorkspaceData);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => refreshWorkspaceData());
  }

  void disposeWorkspace() {
    MessieWorkspaceRefresh.instance.removeListener(refreshWorkspaceData);
  }
}
