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

  List<MessieTodoList> todoLists = const [];
  bool isLoadingTodoLists = false;
  Object? todoListsError;
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
      final session = await _backendSessionService.ensureSession(
        matrix.client,
        matrix.store,
      );
      final todoLists = await _messieTodoService.getTodoLists(
        apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
        jwt: session.token,
        userId: session.userId,
      );
      if (!mounted) return;
      setState(() {
        this.todoLists = todoLists;
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

  Future<void> refreshCalendarEvents() async {
    if (isLoadingCalendarEvents || !mounted) return;

    setState(() {
      isLoadingCalendarEvents = true;
      calendarEventsError = null;
    });

    try {
      final matrix = Matrix.of(context);
      final session = await _backendSessionService.ensureSession(
        matrix.client,
        matrix.store,
      );
      final events = await _messieCalendarService.getUpcomingCalendarEvents(
        apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
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
