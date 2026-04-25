import 'package:fluffychat/pages/todos/todo_list_detail_logic.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:flutter_test/flutter_test.dart';

MessieTodoItem _item({
  required String id,
  required bool completed,
  required String position,
}) => MessieTodoItem(
  id: id,
  listId: 'list-1',
  title: id,
  description: '',
  completed: completed,
  position: position,
);

void main() {
  group('groupTodoItems', () {
    test('splits items into active and completed while preserving order', () {
      final grouped = groupTodoItems([
        _item(id: 'a', completed: false, position: '001'),
        _item(id: 'b', completed: true, position: '002'),
        _item(id: 'c', completed: false, position: '003'),
        _item(id: 'd', completed: true, position: '004'),
      ]);

      expect(grouped.activeItems.map((item) => item.id), ['a', 'c']);
      expect(grouped.completedItems.map((item) => item.id), ['b', 'd']);
    });
  });

  group('reorderTodoItemsInGroup', () {
    final items = [
      _item(id: 'a', completed: false, position: '001'),
      _item(id: 'b', completed: false, position: '002'),
      _item(id: 'c', completed: true, position: '003'),
      _item(id: 'd', completed: true, position: '004'),
    ];

    test('reorders only active items and keeps completed items after them', () {
      final reordered = reorderTodoItemsInGroup(
        items,
        group: TodoItemGroup.active,
        oldIndex: 0,
        newIndex: 1,
      );

      expect(reordered.map((item) => item.id), ['b', 'a', 'c', 'd']);
    });

    test('reorders only completed items and keeps active items stable', () {
      final reordered = reorderTodoItemsInGroup(
        items,
        group: TodoItemGroup.completed,
        oldIndex: 1,
        newIndex: 0,
      );

      expect(reordered.map((item) => item.id), ['a', 'b', 'd', 'c']);
    });

    test('returns grouped order unchanged when indices are invalid', () {
      final reordered = reorderTodoItemsInGroup(
        items,
        group: TodoItemGroup.completed,
        oldIndex: -1,
        newIndex: 0,
      );

      expect(reordered.map((item) => item.id), ['a', 'b', 'c', 'd']);
    });
  });
}
