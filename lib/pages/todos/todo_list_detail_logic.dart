import 'package:fluffychat/services/messie_todo_service.dart';

enum TodoItemGroup { active, completed }

const _fractionalIndexAlphabet =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
const _fractionalIndexBase = 62;
const _canonicalTodoItemBase = 500000;
const _canonicalTodoItemStep = 1000;

class GroupedTodoItems {
  const GroupedTodoItems({
    required this.activeItems,
    required this.completedItems,
  });

  final List<MessieTodoItem> activeItems;
  final List<MessieTodoItem> completedItems;
}

class TodoReorderPlan {
  const TodoReorderPlan({
    required this.items,
    required this.updatedPositions,
  });

  final List<MessieTodoItem> items;
  final Map<String, String> updatedPositions;
}

class TodoInsertPlan {
  const TodoInsertPlan({required this.position, required this.updatedPositions});

  final String position;
  final Map<String, String> updatedPositions;
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

TodoReorderPlan buildTodoReorderPlan(
  List<MessieTodoItem> items, {
  required TodoItemGroup group,
  required int oldIndex,
  required int newIndex,
}) {
  final reordered = reorderTodoItemsInGroup(
    items,
    group: group,
    oldIndex: oldIndex,
    newIndex: newIndex,
  );
  final groupedItems = groupTodoItems(reordered);
  final reorderedGroup = group == TodoItemGroup.active
      ? groupedItems.activeItems
      : groupedItems.completedItems;

  if (newIndex < 0 || newIndex >= reorderedGroup.length) {
    return TodoReorderPlan(items: reordered, updatedPositions: const {});
  }

  final movedItem = reorderedGroup[newIndex];
  final previousPosition = newIndex > 0
      ? reorderedGroup[newIndex - 1].position
      : null;
  final nextPosition = newIndex < reorderedGroup.length - 1
      ? reorderedGroup[newIndex + 1].position
      : null;

  if (previousPosition == null ||
      nextPosition == null ||
      previousPosition.compareTo(nextPosition) < 0) {
    final nextItemPosition = generateTodoItemPosition(
      previousPosition,
      nextPosition,
    );
    return TodoReorderPlan(
      items: reordered,
      updatedPositions: nextItemPosition == movedItem.position
          ? const {}
          : <String, String>{movedItem.id: nextItemPosition},
    );
  }

  final updatedPositions = <String, String>{};
  for (var i = 0; i < reorderedGroup.length; i++) {
    final item = reorderedGroup[i];
    final position = canonicalTodoItemPosition(i);
    if (item.position != position) {
      updatedPositions[item.id] = position;
    }
  }

  return TodoReorderPlan(items: reordered, updatedPositions: updatedPositions);
}

String generateTodoItemPosition(
  String? previousPosition,
  String? nextPosition,
) {
  final previous = previousPosition ?? '';
  final next = nextPosition ?? '';
  return _getMidpoint(previous, next);
}

TodoInsertPlan buildNewTodoItemInsertPlan(List<MessieTodoItem> items) {
  final activeItems = groupTodoItems(items).activeItems;
  if (activeItems.isEmpty) {
    return const TodoInsertPlan(position: 'm', updatedPositions: {});
  }

  final firstPosition = activeItems.first.position;
  final firstNumeric = int.tryParse(firstPosition);
  if (firstNumeric != null) {
    if (firstNumeric > 1) {
      return TodoInsertPlan(
        position: (firstNumeric - 1).toString().padLeft(firstPosition.length, '0'),
        updatedPositions: const {},
      );
    }

	  // We have no room left below the current first numeric key. Only renumber
	  // when the top boundary is already exhausted by duplicated or non-increasing
	  // sibling keys (for example 0 / 0V / 0V). Otherwise we can still prepend
	  // safely with a fractional key before the current first position.
	  final nextPosition = activeItems.length > 1 ? activeItems[1].position : null;
	  final generatedTopPosition = generateTodoItemPosition(null, firstPosition);
	  final needsRenumber =
		  nextPosition != null && generatedTopPosition.compareTo(nextPosition) >= 0;
	  if (needsRenumber) {
		final updatedPositions = <String, String>{};
		for (var i = 0; i < activeItems.length; i++) {
		  final item = activeItems[i];
		  final position = canonicalTodoItemPosition(i + 1);
		  if (item.position != position) {
			updatedPositions[item.id] = position;
		  }
		}
		return TodoInsertPlan(
		  position: canonicalTodoItemPosition(0),
		  updatedPositions: updatedPositions,
		);
	  }

    return TodoInsertPlan(
      position: generateTodoItemPosition(null, firstPosition),
      updatedPositions: const {},
    );
  }

  return TodoInsertPlan(
    position: generateTodoItemPosition(null, firstPosition),
    updatedPositions: const {},
  );
}

int _charToIndex(String char) => _fractionalIndexAlphabet.indexOf(char);

String _indexToChar(int index) => _fractionalIndexAlphabet[index];

String canonicalTodoItemPosition(int index) =>
    (_canonicalTodoItemBase + (index * _canonicalTodoItemStep)).toString().padLeft(12, '0');

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
