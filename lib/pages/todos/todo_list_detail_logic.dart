import 'package:fluffychat/services/messie_todo_service.dart';

enum TodoItemGroup { active, completed }

class GroupedTodoItems {
  const GroupedTodoItems({
    required this.activeItems,
    required this.completedItems,
  });

  final List<MessieTodoItem> activeItems;
  final List<MessieTodoItem> completedItems;
}

GroupedTodoItems groupTodoItems(List<MessieTodoItem> items) {
  final activeItems = <MessieTodoItem>[];
  final completedItems = <MessieTodoItem>[];
  for (final item in items) {
    if (item.completed) {
      completedItems.add(item);
    } else {
      activeItems.add(item);
    }
  }
  return GroupedTodoItems(
    activeItems: activeItems,
    completedItems: completedItems,
  );
}

List<MessieTodoItem> reorderTodoItemsInGroup(
  List<MessieTodoItem> items, {
  required TodoItemGroup group,
  required int oldIndex,
  required int newIndex,
}) {
  final grouped = groupTodoItems(items);
  final activeItems = [...grouped.activeItems];
  final completedItems = [...grouped.completedItems];
  final sectionItems = group == TodoItemGroup.active
      ? activeItems
      : completedItems;

  if (oldIndex < 0 ||
      newIndex < 0 ||
      oldIndex >= sectionItems.length ||
      newIndex >= sectionItems.length ||
      oldIndex == newIndex) {
    return [...activeItems, ...completedItems];
  }

  final movedItem = sectionItems.removeAt(oldIndex);
  sectionItems.insert(newIndex, movedItem);

  return group == TodoItemGroup.active
      ? [...sectionItems, ...completedItems]
      : [...activeItems, ...sectionItems];
}
