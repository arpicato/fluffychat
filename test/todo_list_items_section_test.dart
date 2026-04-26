import 'package:fluffychat/pages/todos/todo_list_detail_logic.dart';
import 'package:fluffychat/pages/todos/todo_list_detail_view.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MessieTodoItem _item({
  required String id,
  required String title,
  required bool completed,
}) => MessieTodoItem(
  id: id,
  listId: 'list-1',
  title: title,
  description: '',
  completed: completed,
  position: id,
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
}
