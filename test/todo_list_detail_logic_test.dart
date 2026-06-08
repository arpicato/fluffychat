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

  group('generateTodoItemPosition', () {
    test('returns initial midpoint for empty list', () {
      expect(generateTodoItemPosition(null, null), 'm');
    });

    test('returns a key between two neighbors', () {
      final position = generateTodoItemPosition('a', 'c');
      expect(position.compareTo('a') > 0, isTrue);
      expect(position.compareTo('c') < 0, isTrue);
    });

    test('appends after the previous item without changing others', () {
      expect(generateTodoItemPosition('m', null), 'n');
    });

    test('prepends before the next item', () {
      final position = generateTodoItemPosition(null, 'm');
      expect(position.compareTo('m') < 0, isTrue);
    });
  });

  group('buildNewTodoItemInsertPlan', () {
    test('places new items at the top of the active section', () {
      final items = [
        _item(id: 'a', completed: false, position: '000000500000'),
        _item(id: 'b', completed: false, position: '000000503000'),
        _item(id: 'c', completed: true, position: '000000502000'),
      ];

      final plan = buildNewTodoItemInsertPlan(items);

      expect(plan.position, '000000499999');
      expect(plan.updatedPositions, isEmpty);
    });

    test('starts from midpoint when there are no active items', () {
      final items = [
        _item(id: 'c', completed: true, position: '002'),
      ];

      final plan = buildNewTodoItemInsertPlan(items);

      expect(plan.position, 'm');
      expect(plan.updatedPositions, isEmpty);
    });

    test('uses fractional position when first numeric position is already at floor', () {
      final items = [
        _item(id: 'a', completed: false, position: '000001'),
        _item(id: 'b', completed: false, position: '000000500000'),
      ];

      final plan = buildNewTodoItemInsertPlan(items);

      expect(plan.position.compareTo('000001') < 0, isTrue);
      expect(plan.updatedPositions, isEmpty);
    });

    test('does not reuse an existing top fractional position', () {
      final items = [
        _item(id: 'a', completed: false, position: '0'),
        _item(id: 'b', completed: false, position: '0V'),
        _item(id: 'c', completed: false, position: '0V'),
      ];

      final plan = buildNewTodoItemInsertPlan(items);

      expect(plan.position, isNot('0V'));
      expect(plan.position.compareTo('0') > 0, isTrue);
      expect(plan.position.compareTo('0V') < 0, isTrue);
    });
  });

  group('buildTodoReorderPlan', () {
    test('updates only the moved item when neighbor positions are ordered', () {
      final items = [
        _item(id: 'a', completed: false, position: '001'),
        _item(id: 'b', completed: false, position: '002'),
        _item(id: 'c', completed: false, position: '003'),
      ];

      final plan = buildTodoReorderPlan(
        items,
        group: TodoItemGroup.active,
        oldIndex: 0,
        newIndex: 1,
      );

      expect(plan.items.map((item) => item.id), ['b', 'a', 'c']);
      expect(plan.updatedPositions.keys, ['a']);
      expect(plan.updatedPositions['a']!.compareTo('002') > 0, isTrue);
      expect(plan.updatedPositions['a']!.compareTo('003') < 0, isTrue);
    });

    test(
      'uses same-group neighbors when other groups are interleaved',
      () {
        final items = [
          _item(id: 'a', completed: false, position: '001'),
          _item(id: 'c', completed: true, position: '002'),
          _item(id: 'b', completed: false, position: '003'),
          _item(id: 'd', completed: true, position: '004'),
        ];

        final plan = buildTodoReorderPlan(
          items,
          group: TodoItemGroup.active,
          oldIndex: 0,
          newIndex: 1,
        );

        expect(plan.items.map((item) => item.id), ['b', 'a', 'c', 'd']);
        expect(plan.updatedPositions.keys, ['a']);
        expect(plan.updatedPositions['a']!.compareTo('003') > 0, isTrue);
      },
    );

    test('renumbers only the reordered group when its positions are corrupted', () {
      final items = [
        _item(id: 'a', completed: false, position: '300'),
        _item(id: 'b', completed: false, position: '100'),
        _item(id: 'c', completed: false, position: '200'),
        _item(id: 'd', completed: true, position: '400'),
      ];

      final plan = buildTodoReorderPlan(
        items,
        group: TodoItemGroup.active,
        oldIndex: 2,
        newIndex: 1,
      );

      expect(plan.items.map((item) => item.id), ['a', 'c', 'b', 'd']);
      expect(
        plan.updatedPositions,
        {
          'a': canonicalTodoItemPosition(0),
          'c': canonicalTodoItemPosition(1),
          'b': canonicalTodoItemPosition(2),
        },
      );
    });
  });
}
