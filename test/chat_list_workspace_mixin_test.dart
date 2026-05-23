import 'package:fluffychat/pages/chat_list/chat_list_workspace_mixin.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/services/messie_workspace_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

    await tester.pumpWidget(
      MaterialApp(
        home: _WorkspaceHost(onState: (value) => state = value),
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
}
