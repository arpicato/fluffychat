import 'package:fluffychat/pages/todos/todo_list_detail_logic.dart';
import 'package:fluffychat/pages/todos/todo_list_detail_view.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MessieTodoItem _item({
  required String id,
  required String title,
  required bool completed,
  String description = '',
  DateTime? dueDate,
}) => MessieTodoItem(
  id: id,
  listId: 'list-1',
  title: title,
  description: description,
  completed: completed,
  position: id,
  dueDate: dueDate,
);

void main() {
  testWidgets('completed items start collapsed and expand on tap', (
    tester,
  ) async {
    var showCompletedItems = false;
    final groupedItems = groupTodoItems([
      _item(id: '001', title: 'Open item', completed: false),
      _item(id: '002', title: 'Done item', completed: true),
    ]);

    Future<void> pumpSection() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => CustomScrollView(
                slivers: [
                  TodoListItemsSection(
                    groupedItems: groupedItems,
                    showCompletedItems: showCompletedItems,
                    formatTimestamp: (_) => '',
                    onShowCompletedItemsChanged: (value) {
                      setState(() => showCompletedItems = value);
                    },
                    onToggleItem: (item, completed) async {},
                    onMoveItem: (group, oldIndex, newIndex) async {},
                    onEditItem: (item) async {},
                    onDeleteItem: (item) async {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    await pumpSection();

    expect(find.text('Open item'), findsOneWidget);
    expect(find.text('Done (1)'), findsOneWidget);
    expect(find.text('Done item'), findsNothing);
    expect(find.byTooltip('Reorder'), findsOneWidget);

    await tester.tap(find.text('Done (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Done item'), findsOneWidget);
    expect(find.byTooltip('Reorder'), findsNWidgets(2));
  });

  testWidgets('rebuilds cleanly when switching visible reorderable sections', (
    tester,
  ) async {
    var groupedItems = groupTodoItems([
      _item(id: '001', title: 'Open item', completed: false),
      _item(id: '002', title: 'Done item', completed: true),
    ]);
    var showCompletedItems = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => CustomScrollView(
              slivers: [
                TodoListItemsSection(
                  groupedItems: groupedItems,
                  showCompletedItems: showCompletedItems,
                  formatTimestamp: (_) => '',
                  onShowCompletedItemsChanged: (value) {
                    setState(() => showCompletedItems = value);
                  },
                  onToggleItem: (item, completed) async {},
                  onMoveItem: (group, oldIndex, newIndex) async {},
                  onEditItem: (item) async {},
                  onDeleteItem: (item) async {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    groupedItems = groupTodoItems([
      _item(id: '002', title: 'Done item', completed: true),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              TodoListItemsSection(
                groupedItems: groupedItems,
                showCompletedItems: true,
                formatTimestamp: (_) => '',
                onShowCompletedItemsChanged: (_) {},
                onToggleItem: (item, completed) async {},
                onMoveItem: (group, oldIndex, newIndex) async {},
                onEditItem: (item) async {},
                onDeleteItem: (item) async {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Done item'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('todo item rows stay compact and ellipsize long content', (
    tester,
  ) async {
    final groupedItems = groupTodoItems([
      _item(
        id: '001',
        title: 'Very long title ' * 20,
        description: 'Very long description ' * 40,
        dueDate: DateTime.utc(2026, 5, 24),
        completed: false,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              TodoListItemsSection(
                groupedItems: groupedItems,
                showCompletedItems: false,
                formatTimestamp: (_) => 'May 24',
                onShowCompletedItemsChanged: (_) {},
                onToggleItem: (item, completed) async {},
                onMoveItem: (group, oldIndex, newIndex) async {},
                onEditItem: (item) async {},
                onDeleteItem: (item) async {},
              ),
            ],
          ),
        ),
      ),
    );

    final titleText = tester.widget<Text>(find.textContaining('Very long title'));
    final subtitleText = tester.widget<Text>(find.textContaining('Very long description'));

    expect(titleText.maxLines, 1);
    expect(titleText.overflow, TextOverflow.ellipsis);
    expect(subtitleText.maxLines, 2);
    expect(subtitleText.overflow, TextOverflow.ellipsis);
  });

  testWidgets('todo row text collapses embedded newlines before ellipsis', (
    tester,
  ) async {
    final groupedItems = groupTodoItems([
      _item(
        id: '001',
        title: 'Title line one\nline two\nline three',
        description:
            'Description line one\nline two\nline three\nline four\nline five',
        completed: false,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              TodoListItemsSection(
                groupedItems: groupedItems,
                showCompletedItems: false,
                formatTimestamp: (_) => '',
                onShowCompletedItemsChanged: (_) {},
                onToggleItem: (item, completed) async {},
                onMoveItem: (group, oldIndex, newIndex) async {},
                onEditItem: (item) async {},
                onDeleteItem: (item) async {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.textContaining('\n'), findsNothing);
    expect(find.text('Title line one line two line three'), findsOneWidget);
    expect(
      find.text(
        'Description line one line two line three line four line five',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping a todo item row opens edit behavior', (tester) async {
    final groupedItems = groupTodoItems([
      _item(
        id: '001',
        title: 'Open item',
        description: 'Description',
        completed: false,
      ),
    ]);
    MessieTodoItem? editedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              TodoListItemsSection(
                groupedItems: groupedItems,
                showCompletedItems: false,
                formatTimestamp: (_) => '',
                onShowCompletedItemsChanged: (_) {},
                onToggleItem: (item, completed) async {},
                onMoveItem: (group, oldIndex, newIndex) async {},
                onEditItem: (item) async {
                  editedItem = item;
                },
                onDeleteItem: (item) async {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open item'));
    await tester.pump();

    expect(editedItem?.id, '001');
  });
}
