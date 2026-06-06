import 'package:fluffychat/pages/chat_list/chat_list_todo_item.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

MessieTodoList _todoList({
  required String id,
  required String title,
  required String description,
}) => MessieTodoList(
  id: id,
  ownerId: 'owner',
  title: title,
  description: description,
  createdAt: DateTime.utc(2026, 1, 1, 12),
  updatedAt: DateTime.utc(2026, 1, 1, 12),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_US');
  });

  testWidgets('chat list todo item reserves chat-like row height without description', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatListTodoItem(
            todoList: _todoList(id: 'a', title: 'List', description: ''),
            onTap: () {},
          ),
        ),
      ),
    );

    final tile = tester.widget<ListTile>(find.byType(ListTile));
    expect(tile.minTileHeight, 72);
    expect(find.text(' '), findsOneWidget);
  });

  testWidgets('chat list todo item shows pin icon when pinned', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatListTodoItem(
            todoList: _todoList(
              id: 'a',
              title: 'Pinned list',
              description: 'Description',
            ),
            pinned: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.push_pin), findsOneWidget);
  });

  testWidgets('chat list todo item shows context menu on right click', (
    tester,
  ) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatListTodoItem(
            todoList: _todoList(
              id: 'a',
              title: 'Pinned list',
              description: 'Description',
            ),
            onTap: () {},
            onShowContextMenu: (_) {
              opened = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ChatListTodoItem), buttons: kSecondaryButton);
    await tester.pump();

    expect(opened, isTrue);
  });
}
