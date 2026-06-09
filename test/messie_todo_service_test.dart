import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MessieTodoList.activityAt prefers last activity time', () {
    final todoList = MessieTodoList(
      id: 'list-1',
      ownerId: 'user-1',
      title: 'Daily list',
      description: 'Check current work',
      pinned: false,
      createdAt: DateTime.utc(2026, 5, 20, 8),
      updatedAt: DateTime.utc(2026, 5, 21, 9),
      lastActivityAt: DateTime.utc(2026, 5, 24, 7, 45),
    );

    expect(todoList.activityAt, DateTime.utc(2026, 5, 24, 7, 45));
  });

  test('MessieTodoList.activityAt falls back to updated and created times', () {
    final updatedOnly = MessieTodoList(
      id: 'list-2',
      ownerId: 'user-1',
      title: 'Updated only',
      description: '',
      pinned: false,
      createdAt: DateTime.utc(2026, 5, 20, 8),
      updatedAt: DateTime.utc(2026, 5, 21, 9),
    );
    final createdOnly = MessieTodoList(
      id: 'list-3',
      ownerId: 'user-1',
      title: 'Created only',
      description: '',
      pinned: false,
      createdAt: DateTime.utc(2026, 5, 20, 8),
    );

    expect(updatedOnly.activityAt, DateTime.utc(2026, 5, 21, 9));
    expect(createdOnly.activityAt, DateTime.utc(2026, 5, 20, 8));
  });
}
