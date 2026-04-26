import 'package:fluffychat/services/messie_todo_service.dart';

enum TodoItemGroup { active, completed }

const _fractionalIndexAlphabet =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
const _fractionalIndexBase = 62;

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

String generateTodoItemPosition(
  String? previousPosition,
  String? nextPosition,
) {
  final previous = previousPosition ?? '';
  final next = nextPosition ?? '';
  return _getMidpoint(previous, next);
}

int _charToIndex(String char) => _fractionalIndexAlphabet.indexOf(char);

String _indexToChar(int index) => _fractionalIndexAlphabet[index];

String _incrementPosition(String key) {
  var result = '';
  var carry = 1;
  for (var i = key.length - 1; i >= 0; i--) {
    final index = _charToIndex(key[i]) + carry;
    carry = index ~/ _fractionalIndexBase;
    result = _indexToChar(index % _fractionalIndexBase) + result;
  }
  if (carry > 0) {
    result = _indexToChar(carry) + result;
  }
  return result;
}

String _getMidpoint(String previous, String next) {
  if (previous.isEmpty && next.isEmpty) {
    return 'm';
  }

  if (previous.isEmpty) {
    var midpoint = '';
    for (var i = 0; i < next.length; i++) {
      final index = _charToIndex(next[i]);
      if (index > 0) {
        midpoint += _indexToChar(index ~/ 2);
        return midpoint;
      }
      midpoint += _fractionalIndexAlphabet[0];
    }
    return midpoint + _fractionalIndexAlphabet[_fractionalIndexBase ~/ 2];
  }

  if (next.isEmpty) {
    return _incrementPosition(previous);
  }

  var newKey = '';
  var i = 0;
  while (true) {
    final previousChar = i < previous.length
        ? previous[i]
        : _fractionalIndexAlphabet[0];
    final nextChar = i < next.length
        ? next[i]
        : _fractionalIndexAlphabet[_fractionalIndexBase - 1];
    final previousIndex = _charToIndex(previousChar);
    final nextIndex = _charToIndex(nextChar);

    if (previousIndex == nextIndex) {
      newKey += previousChar;
      i++;
      continue;
    }

    if (nextIndex - previousIndex == 1) {
      newKey += previousChar;
      i++;
      newKey += _fractionalIndexAlphabet[_fractionalIndexBase ~/ 2];
      return newKey;
    }

    newKey += _indexToChar((previousIndex + nextIndex) ~/ 2);
    return newKey;
  }
}
