import 'package:fluffychat/pages/chat_list/chat_list_workspace_mixin.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/services/messie_workspace_refresh.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeClient extends Fake implements Client {}

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
  const _WorkspaceHost({required this.onState});

  final void Function(_WorkspaceHostState state) onState;

  @override
  State<_WorkspaceHost> createState() => _WorkspaceHostState();
}

class _WorkspaceHostState extends State<_WorkspaceHost>
    with ChatListWorkspaceMixin<_WorkspaceHost> {
  var refreshCalls = 0;

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

MessieTodoList _todoList(String id, String title) => MessieTodoList(
  id: id,
  title: title,
  description: '',
  ownerId: 'owner',
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('workspace refresh bump triggers chat list workspace refresh', (
    tester,
  ) async {
    late _WorkspaceHostState state;

    await tester.pumpWidget(
      MaterialApp(
        home: _WorkspaceHost(onState: (value) => state = value),
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

  testWidgets('workspace stores pinned todo list ids', (tester) async {
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

    await state.setTodoListPinned('list-1', true);

    expect(state.isTodoListPinned('list-1'), isTrue);
    expect(
      prefs.getStringList(ChatListWorkspaceMixin.pinnedTodoListsStoreKey),
      ['list-1'],
    );

    await state.setTodoListPinned('list-1', false);

    expect(state.isTodoListPinned('list-1'), isFalse);
    expect(
      prefs.getStringList(ChatListWorkspaceMixin.pinnedTodoListsStoreKey),
      isEmpty,
    );
  });
}
