import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messie_api/messie_api.dart' as api;

class RecordingMessieTodoSdk implements MessieTodoSdk {
  DateTime? createdDueDate;
  DateTime? updatedDueDate;

  @override
  Future<api.TodoItem> createTodoItem({
    required String listId,
    required String title,
    required String description,
    required bool completed,
    required String position,
    DateTime? dueDate,
  }) async {
    createdDueDate = dueDate;
    return api.TodoItem(
      (builder) => builder
        ..id = 'item-1'
        ..listId = listId
        ..title = title
        ..description = description
        ..completed = completed
        ..position = position
        ..dueDate = dueDate,
    );
  }

  @override
  Future<api.TodoItem> updateTodoItem({
    required String listId,
    required String itemId,
    required String title,
    required String description,
    required bool completed,
    required String position,
    DateTime? dueDate,
  }) async {
    updatedDueDate = dueDate;
    return api.TodoItem(
      (builder) => builder
        ..id = itemId
        ..listId = listId
        ..title = title
        ..description = description
        ..completed = completed
        ..position = position
        ..dueDate = dueDate,
    );
  }

  @override
  Future<void> addCollaborator({
    required String listId,
    required String userId,
  }) => Future.value();

  @override
  Future<api.TodoList> createTodoList({
    required String title,
    required String description,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteTodoItem({
    required String listId,
    required String itemId,
  }) => Future.value();

  @override
  Future<void> deleteTodoList({required String listId}) => Future.value();

  @override
  Future<List<api.CollaboratorDetail>> getCollaborators({
    required String listId,
  }) => throw UnimplementedError();

  @override
  Future<List<api.TodoItem>> getTodoItems({required String listId}) =>
      throw UnimplementedError();

  @override
  Future<api.TodoList> getTodoListById({required String listId}) =>
      throw UnimplementedError();

  @override
  Future<List<api.TodoList>> getTodoLists({required String userId}) =>
      throw UnimplementedError();

  @override
  Future<api.User?> getUserByMatrixId({required String matrixId}) =>
      throw UnimplementedError();

  @override
  Future<void> removeCollaborator({
    required String listId,
    required String userId,
  }) => Future.value();

  @override
  Future<api.TodoList> updateTodoList({
    required String listId,
    required String title,
    required String description,
  }) => throw UnimplementedError();
}

void main() {
  group('MessieTodoService', () {
    test('normalizes created due dates to UTC', () async {
      final sdk = RecordingMessieTodoSdk();
      final service = MessieTodoService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      await service.createTodoItem(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        listId: 'list-1',
        title: 'Test item',
        description: 'Description',
        completed: false,
        position: 'a0',
        dueDate: DateTime(2026, 4, 16),
      );

      expect(sdk.createdDueDate, DateTime.utc(2026, 4, 16));
      expect(sdk.createdDueDate?.isUtc, isTrue);
    });

    test('normalizes updated due dates to UTC', () async {
      final sdk = RecordingMessieTodoSdk();
      final service = MessieTodoService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      await service.updateTodoItem(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        listId: 'list-1',
        itemId: 'item-1',
        title: 'Test item',
        description: 'Description',
        completed: false,
        position: 'a0',
        dueDate: DateTime(2026, 4, 16),
      );

      expect(sdk.updatedDueDate, DateTime.utc(2026, 4, 16));
      expect(sdk.updatedDueDate?.isUtc, isTrue);
    });
  });
}
