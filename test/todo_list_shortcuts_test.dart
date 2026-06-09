import 'package:fluffychat/pages/todos/todo_list_detail_view.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

MessieTodoItem _item({
  required String id,
  required String title,
  bool completed = false,
}) => MessieTodoItem(
  id: id,
  listId: 'list-1',
  title: title,
  description: '',
  completed: completed,
  position: id,
);

Color? _tileCardColor(WidgetTester tester, Finder finder) =>
    tester.widget<Card>(
      find.ancestor(of: finder, matching: find.byType(Card)).first,
    ).color;

Widget _focusedCard(BuildContext context, TodoShortcutBindings bindings, MessieTodoItem item) =>
    TodoShortcutFocusItem(
      bindings: bindings,
      targetId: item.id,
      child: (context, focused) => Card(
        color: focused ? Theme.of(context).colorScheme.secondaryContainer : null,
        child: ListTile(title: Text(item.title)),
      ),
    );

void main() {
  testWidgets('todo shortcut scope triggers requested actions', (tester) async {
    final items = [
      _item(id: '001', title: 'First item'),
      _item(id: '002', title: 'Second item', completed: true),
    ];
    var createCalls = 0;
    final edited = <String>[];
    final toggled = <String>[];
    final deleted = <String>[];
    final reordered = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoListShortcutScope(
            scrollController: ScrollController(),
            targets: [
              const TodoShortcutTarget.addRow(),
              ...items.map(TodoShortcutTarget.item),
            ],
            onCreateItem: () {
              createCalls++;
            },
            onEditItem: (item) async {
              edited.add(item.id);
            },
            onToggleItem: (item, completed) async {
              toggled.add('${item.id}:$completed');
            },
            onDeleteItem: (item) async {
              deleted.add(item.id);
            },
            onReorderItem: (item, moveDown) async {
              reordered.add('${item.id}:${moveDown ? 'down' : 'up'}');
            },
            builder: (context, bindings) => Column(
              children: [
                TodoShortcutFocusItem(
                  bindings: bindings,
                  targetId: 'add-row',
                  child: (context, focused) => TodoListAddItemRow(
                    onTap: () {},
                    focused: focused,
                  ),
                ),
                ...items.map(
                  (item) => _focusedCard(context, bindings, item),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(
      _tileCardColor(tester, find.byKey(const ValueKey('todo-add-item-row'))),
      theme.colorScheme.secondaryContainer,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    expect(createCalls, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      _tileCardColor(tester, find.byKey(const ValueKey('todo-add-item-row'))),
      isNull,
    );
    expect(
      tester.widget<Card>(find.widgetWithText(Card, 'First item')).color,
      theme.colorScheme.secondaryContainer,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
    expect(edited, ['001']);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(toggled, ['001:true', '001:true']);

    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    expect(deleted, ['001', '001']);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      tester.widget<Card>(find.widgetWithText(Card, 'First item')).color,
      theme.colorScheme.secondaryContainer,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    expect(reordered, ['001:down', '001:up']);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(toggled, ['001:true', '001:true', '002:false']);
  });

  testWidgets('delete shortcut can be gated by confirmation', (tester) async {
    final item = _item(id: '001', title: 'Confirm delete');
    var pendingDelete = false;
    var confirmedDelete = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: TodoListShortcutScope(
              scrollController: ScrollController(),
              targets: [const TodoShortcutTarget.addRow(), TodoShortcutTarget.item(item)],
              onCreateItem: () {},
              onEditItem: (_) async {},
              onToggleItem: (_, _) async {},
              onDeleteItem: (_) async {
                setState(() {
                  pendingDelete = true;
                });
              },
              onReorderItem: (_, _) async {},
              builder: (context, bindings) => Stack(
                children: [
                  TodoShortcutFocusItem(
                    bindings: bindings,
                    targetId: 'add-row',
                    child: (context, _) => const SizedBox.shrink(),
                  ),
                  TodoShortcutFocusItem(
                    bindings: bindings,
                    targetId: item.id,
                    child: (context, _) => const SizedBox.expand(),
                  ),
                  if (pendingDelete)
                    Center(
                      child: AlertDialog(
                        title: const Text('Delete todo item?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                pendingDelete = false;
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                pendingDelete = false;
                                confirmedDelete = true;
                              });
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();

    expect(find.text('Delete todo item?'), findsOneWidget);
    expect(confirmedDelete, isFalse);

    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(confirmedDelete, isTrue);
    expect(find.text('Delete todo item?'), findsNothing);
  });

  testWidgets('todo shortcut scope handles held arrow repeat on focused rows', (
    tester,
  ) async {
    final items = [
      _item(id: '001', title: 'First item'),
      _item(id: '002', title: 'Second item'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoListShortcutScope(
            scrollController: ScrollController(),
            targets: [
              const TodoShortcutTarget.addRow(),
              ...items.map(TodoShortcutTarget.item),
            ],
            onCreateItem: () {},
            onEditItem: (_) async {},
            onToggleItem: (_, _) async {},
            onDeleteItem: (_) async {},
            onReorderItem: (_, _) async {},
            builder: (context, bindings) => Column(
              children: [
                TodoShortcutFocusItem(
                  bindings: bindings,
                  targetId: 'add-row',
                  child: (context, focused) => TodoListAddItemRow(
                    onTap: () {},
                    focused: focused,
                  ),
                ),
                ...items.map((item) => _focusedCard(context, bindings, item)),
              ],
            ),
          ),
        ),
      ),
    );

    final theme = Theme.of(tester.element(find.byType(Scaffold)));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      tester.widget<Card>(find.widgetWithText(Card, 'First item')).color,
      theme.colorScheme.secondaryContainer,
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      tester.widget<Card>(find.widgetWithText(Card, 'Second item')).color,
      theme.colorScheme.secondaryContainer,
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
  });

  testWidgets('focused todo row scrolls into view when arrowing through list', (
    tester,
  ) async {
    final items = List.generate(
      16,
      (index) => _item(
        id: index.toString().padLeft(3, '0'),
        title: 'Item $index',
      ),
    );
    final scrollController = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 220,
            child: TodoListShortcutScope(
              scrollController: scrollController,
              targets: [
                const TodoShortcutTarget.addRow(),
                ...items.map(TodoShortcutTarget.item),
              ],
              onCreateItem: () {},
              onEditItem: (_) async {},
              onToggleItem: (_, _) async {},
              onDeleteItem: (_) async {},
              onReorderItem: (_, _) async {},
              builder: (context, bindings) => SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    TodoShortcutFocusItem(
                      bindings: bindings,
                      targetId: 'add-row',
                      child: (context, focused) => TodoListAddItemRow(
                        onTap: () {},
                        focused: focused,
                      ),
                    ),
                    ...items.map(
                      (item) => _focusedCard(context, bindings, item),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (var i = 0; i < 12; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(
      tester.widget<Card>(find.widgetWithText(Card, 'Item 11')).color,
      theme.colorScheme.secondaryContainer,
    );
    expect(scrollController.offset, greaterThan(0));
    expect(find.text('Item 11'), findsOneWidget);
  });
}
