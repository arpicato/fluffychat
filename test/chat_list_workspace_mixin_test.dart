import 'package:fluffychat/pages/chat_list/chat_list_workspace_mixin.dart';
import 'package:fluffychat/services/backend_session_service.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/services/messie_workspace_snapshot_service.dart';
import 'package:fluffychat/services/messie_workspace_refresh.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:messie_api/messie_api.dart' as api;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeClient extends Fake implements Client {
  _FakeClient({this.userID = '@user:example.com'});

  final String? userID;
}

class _FakeMatrixState with DiagnosticableTreeMixin implements MatrixState {
  _FakeMatrixState({required this.client, required this.store});

  @override
  final Client client;

  @override
  final SharedPreferences store;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WorkspaceHost extends StatefulWidget {
  const _WorkspaceHost({
    required this.onState,
    this.todoService,
    this.session,
  });

  final void Function(_WorkspaceHostState state) onState;
  final MessieTodoService? todoService;
  final BackendSession? session;

  @override
  State<_WorkspaceHost> createState() => _WorkspaceHostState();
}

class _WorkspaceHostState extends State<_WorkspaceHost>
    with ChatListWorkspaceMixin<_WorkspaceHost> {
  var refreshCalls = 0;

  @override
  MessieTodoService get messieTodoService =>
      widget.todoService ?? super.messieTodoService;

  @override
  Future<BackendSession> ensureBackendSession(MatrixState matrix) async =>
      widget.session ??
      BackendSession(
        token: 'token',
        mxid: '@user:example.com',
        userId: 'user-1',
        expiresAt: null,
      );

  @override
  String get backendApiBaseUrl => 'https://example.test/api/v1';

  @override
  bool get enableMessieRealtime => false;

  @override
  void initState() {
    super.initState();
    initWorkspace();
    widget.onState(this);
  }

  @override
  void dispose() {
    disposeWorkspace();
    super.dispose();
  }

  @override
  Future<void> refreshWorkspaceData() async {
    refreshCalls += 1;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _FakeTodoSdk implements MessieTodoSdk {
  _FakeTodoSdk(this.todoLists);

  final Map<String, api.TodoList> todoLists;

  @override
  Future<api.TodoList> setTodoListPin({required String listId, required bool pinned}) async {
    final current = todoLists[listId]!;
    final updated = current.rebuild((b) => b..pinned = pinned);
    todoLists[listId] = updated;
    return updated;
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MessieTodoList _todoList(String id, String title) => MessieTodoList(
  id: id,
  title: title,
  description: '',
  ownerId: 'owner',
  pinned: false,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

MessieCalendarEvent _calendarEvent(String id, String title) =>
    MessieCalendarEvent(
      id: id,
      sourceId: 'source-1',
      externalUid: 'external-$id',
      title: title,
      description: '',
      location: '',
      startsAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      endsAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
      allDay: false,
      status: 'confirmed',
      timezone: 'UTC',
      sourceDisplayName: 'Calendar',
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('workspace refresh bump triggers chat list workspace refresh', (
    tester,
  ) async {
    late _WorkspaceHostState state;
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      Provider<MatrixState>.value(
        value: _FakeMatrixState(client: _FakeClient(), store: prefs),
        child: MaterialApp(
          home: _WorkspaceHost(onState: (value) => state = value),
        ),
      ),
    );

    final before = state.refreshCalls;
    MessieWorkspaceRefresh.instance.bump();
    await tester.pump();

    expect(state.refreshCalls, before + 1);
  });

  testWidgets('workspace state removes deleted optimistic todo lists', (
    tester,
  ) async {
    late _WorkspaceHostState state;
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      Provider<MatrixState>.value(
        value: _FakeMatrixState(client: _FakeClient(), store: prefs),
        child: MaterialApp(
          home: _WorkspaceHost(onState: (value) => state = value),
        ),
      ),
    );

    final created = _todoList('list-1', 'Created');
    state.addTodoListToWorkspace(created);
    await tester.pump();

    expect(state.todoLists.map((list) => list.id), ['list-1']);

    state.todoLists = const [];
    state.removeTodoListFromWorkspace('list-1');
    await tester.pump();

    expect(state.todoLists, isEmpty);
  });

  testWidgets('workspace updates pinned todo lists from backend response', (tester) async {
    late _WorkspaceHostState state;
    final prefs = await SharedPreferences.getInstance();
    final sdk = _FakeTodoSdk({
      'list-1': api.TodoList(
        (b) => b
          ..id = 'list-1'
          ..ownerId = 'owner'
          ..title = 'List'
          ..description = ''
          ..pinned = false,
      ),
    });
    await tester.pumpWidget(
      Provider<MatrixState>.value(
        value: _FakeMatrixState(client: _FakeClient(), store: prefs),
        child: MaterialApp(
          home: _WorkspaceHost(
            onState: (value) => state = value,
            todoService: MessieTodoService(
              sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
            ),
            session: BackendSession(
              token: 'token',
              mxid: '@user:example.com',
              userId: 'user-1',
              expiresAt: null,
            ),
          ),
        ),
      ),
    );

    state.todoLists = [_todoList('list-1', 'List')];

    await state.setTodoListPinned('list-1', true);

    expect(state.isTodoListPinned('list-1'), isTrue);

    await state.setTodoListPinned('list-1', false);

    expect(state.isTodoListPinned('list-1'), isFalse);
  });

  testWidgets('workspace hydrates cached snapshot before first refresh completes', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    const snapshotService = MessieWorkspaceSnapshotService();
    await snapshotService.write(
      store: prefs,
      userKey: '@user:example.com',
      snapshot: MessieWorkspaceSnapshot(
        savedAt: DateTime.utc(2026, 1, 1),
        todoLists: [_todoList('list-1', 'Cached todo')],
        upcomingCalendarEvents: [_calendarEvent('event-1', 'Cached event')],
      ),
    );

    late _WorkspaceHostState state;
    await tester.pumpWidget(
      Provider<MatrixState>.value(
        value: _FakeMatrixState(client: _FakeClient(), store: prefs),
        child: MaterialApp(
          home: _WorkspaceHost(
            onState: (value) => state = value,
            session: BackendSession(
              token: 'token',
              mxid: '@user:example.com',
              userId: 'user-1',
              expiresAt: null,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(state.todoLists.map((list) => list.title), ['Cached todo']);
    expect(
      state.upcomingCalendarEvents.map((event) => event.title),
      ['Cached event'],
    );
    expect(state.isWorkspaceSnapshotHydrated, isTrue);
    expect(state.isWorkspaceReadyForFirstPaint, isTrue);
  });
}
