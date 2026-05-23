import 'package:dio/dio.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messie_api/messie_api.dart' as api;

DateTime _expectedUtc(DateTime value) => value.toUtc();

class RecordingMessieTodoSdk implements MessieTodoSdk {
  DateTime? createdDueDate;
  DateTime? updatedDueDate;
  Object? todoListsError;
  String? requestedTodoListsUserId;

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
  Future<List<api.TodoList>> getTodoLists({required String userId}) async {
    requestedTodoListsUserId = userId;
    if (todoListsError != null) {
      throw todoListsError!;
    }
    return const [];
  }

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
    test('maps collaborator identity fields for UI display', () {
      final collaborator = MessieTodoCollaborator.fromApi(
        api.CollaboratorDetail(
          (builder) => builder
            ..listId = 'list-1'
            ..collaboratorId = 'user-1'
            ..username = 'todochat2'
            ..matrixId = '@todochat2:messie.localhost'
            ..displayName = 'Todo Chat 2',
        ),
      );

      expect(collaborator.displayName, 'Todo Chat 2');
      expect(collaborator.matrixId, '@todochat2:messie.localhost');
      expect(collaborator.collaboratorId, 'user-1');
    });

    test('normalizes created due dates to UTC', () async {
      final sdk = RecordingMessieTodoSdk();
      final service = MessieTodoService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );
      final dueDate = DateTime(2026, 4, 16);

      await service.createTodoItem(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        listId: 'list-1',
        title: 'Test item',
        description: 'Description',
        completed: false,
        position: 'a0',
        dueDate: dueDate,
      );

      expect(sdk.createdDueDate, _expectedUtc(dueDate));
      expect(sdk.createdDueDate?.isUtc, isTrue);
    });

    test('normalizes updated due dates to UTC', () async {
      final sdk = RecordingMessieTodoSdk();
      final service = MessieTodoService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );
      final dueDate = DateTime(2026, 4, 16);

      await service.updateTodoItem(
        apiBaseUrl: 'http://localhost:8080/api/v1',
        jwt: 'jwt',
        listId: 'list-1',
        itemId: 'item-1',
        title: 'Test item',
        description: 'Description',
        completed: false,
        position: 'a0',
        dueDate: dueDate,
      );

      expect(sdk.updatedDueDate, _expectedUtc(dueDate));
      expect(sdk.updatedDueDate?.isUtc, isTrue);
    });

    test('fails clearly when todo load is called without backend userId', () async {
      final sdk = RecordingMessieTodoSdk();
      final service = MessieTodoService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      await expectLater(
        () => service.getTodoLists(
          apiBaseUrl: 'http://localhost:8080/api/v1',
          jwt: 'jwt',
          userId: '  ',
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('backend session is missing userId'),
          ),
        ),
      );

      expect(sdk.requestedTodoListsUserId, isNull);
    });

    test('preserves non-Dio todo load failure details', () async {
      final sdk = RecordingMessieTodoSdk()
        ..todoListsError = StateError('invalid userId format');
      final service = MessieTodoService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      await expectLater(
        () => service.getTodoLists(
          apiBaseUrl: 'http://localhost:8080/api/v1',
          jwt: 'jwt',
          userId: 'not-a-uuid',
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Failed to load todos: Bad state: invalid userId format'),
          ),
        ),
      );
    });

    test('keeps Dio status and body details for todo load failures', () async {
      final sdk = RecordingMessieTodoSdk()
        ..todoListsError = DioException(
          requestOptions: RequestOptions(path: '/todolists'),
          response: Response(
            requestOptions: RequestOptions(path: '/todolists'),
            statusCode: 400,
            data: {'error': 'invalid user id'},
          ),
          type: DioExceptionType.badResponse,
        );
      final service = MessieTodoService(
        sdkFactory: ({required apiBaseUrl, required jwt}) => sdk,
      );

      await expectLater(
        () => service.getTodoLists(
          apiBaseUrl: 'http://localhost:8080/api/v1',
          jwt: 'jwt',
          userId: 'not-a-uuid',
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Failed to load todos (400): {"error":"invalid user id"}'),
          ),
        ),
      );
    });
  });
}
