import 'package:dio/dio.dart';
import 'package:fluffychat/services/messie_error_service.dart';
import 'package:matrix/matrix.dart';
import 'package:messie_api/messie_api.dart' as api;

DateTime? _normalizeMessieDateTime(DateTime? value) => value?.toUtc();

String _normalizeMessieApiBaseUrl(String value) =>
    value.endsWith('/') ? value.substring(0, value.length - 1) : value;

class MessieTodoList {
  MessieTodoList({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.pinned,
    this.lastActivityAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final bool pinned;
  final DateTime? lastActivityAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime? get activityAt => lastActivityAt ?? updatedAt ?? createdAt;

  factory MessieTodoList.fromApi(api.TodoList list) => MessieTodoList(
    id: list.id,
    ownerId: list.ownerId,
    title: list.title,
    description: list.description,
    pinned: list.pinned,
    lastActivityAt: list.lastActivityAt,
    createdAt: list.createdAt,
    updatedAt: list.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'pinned': pinned,
    'lastActivityAt': lastActivityAt?.toUtc().toIso8601String(),
    'createdAt': createdAt?.toUtc().toIso8601String(),
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
  };

  factory MessieTodoList.fromJson(Map<String, Object?> json) => MessieTodoList(
    id: json['id'] as String? ?? '',
    ownerId: json['ownerId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    pinned: json['pinned'] as bool? ?? false,
    lastActivityAt: _parseMessieDateTime(json['lastActivityAt']),
    createdAt: _parseMessieDateTime(json['createdAt']),
    updatedAt: _parseMessieDateTime(json['updatedAt']),
  );
}

DateTime? _parseMessieDateTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}

class MessieTodoItem {
  MessieTodoItem({
    required this.id,
    required this.listId,
    required this.title,
    required this.description,
    required this.completed,
    required this.position,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String listId;
  final String title;
  final String description;
  final bool completed;
  final String position;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MessieTodoItem.fromApi(api.TodoItem item) => MessieTodoItem(
    id: item.id,
    listId: item.listId,
    title: item.title,
    description: item.description,
    completed: item.completed,
    position: item.position,
    dueDate: item.dueDate,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
  );
}

class MessieTodoCollaborator {
  MessieTodoCollaborator({
    required this.listId,
    required this.collaboratorId,
    required this.username,
    required this.matrixId,
    this.displayName,
  });

  final String listId;
  final String collaboratorId;
  final String username;
  final String matrixId;
  final String? displayName;

  factory MessieTodoCollaborator.fromApi(api.CollaboratorDetail collaborator) =>
      MessieTodoCollaborator(
        listId: collaborator.listId,
        collaboratorId: collaborator.collaboratorId,
        username: collaborator.username,
        matrixId: collaborator.matrixId,
        displayName: collaborator.displayName,
      );
}

class MessieUser {
  MessieUser({
    required this.id,
    required this.email,
    required this.matrixId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String matrixId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MessieUser.fromApi(api.User user) => MessieUser(
    id: user.id,
    email: user.email,
    matrixId: user.matrixId,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  );
}

abstract class MessieTodoSdk {
  Future<List<api.TodoList>> getTodoLists({required String userId});

  Future<api.TodoList> getTodoListById({required String listId});

  Future<api.TodoList> createTodoList({
    required String title,
    required String description,
  });

  Future<api.TodoList> updateTodoList({
    required String listId,
    required String title,
    required String description,
  });

  Future<api.TodoList> setTodoListPin({
    required String listId,
    required bool pinned,
  });

  Future<void> deleteTodoList({required String listId});

  Future<List<api.TodoItem>> getTodoItems({required String listId});

  Future<api.TodoItem> createTodoItem({
    required String listId,
    required String title,
    required String description,
    required bool completed,
    required String position,
    DateTime? dueDate,
  });

  Future<api.TodoItem> updateTodoItem({
    required String listId,
    required String itemId,
    required String title,
    required String description,
    required bool completed,
    required String position,
    DateTime? dueDate,
  });

  Future<void> deleteTodoItem({required String listId, required String itemId});

  Future<List<api.CollaboratorDetail>> getCollaborators({
    required String listId,
  });

  Future<void> addCollaborator({
    required String listId,
    required String userId,
  });

  Future<void> removeCollaborator({
    required String listId,
    required String userId,
  });

  Future<api.User?> getUserByMatrixId({required String matrixId});
}

class GeneratedMessieTodoSdk implements MessieTodoSdk {
  GeneratedMessieTodoSdk({required String apiBaseUrl, required String jwt})
    : _api = _createApi(apiBaseUrl: apiBaseUrl, jwt: jwt);

  final api.DefaultApi _api;

  static api.DefaultApi _createApi({
    required String apiBaseUrl,
    required String jwt,
  }) {
    final sdk = api.MessieApi(
      basePathOverride: _normalizeMessieApiBaseUrl(apiBaseUrl),
    );
    sdk.setBearerAuth('bearerAuth', jwt);
    return sdk.getDefaultApi();
  }

  @override
  Future<List<api.TodoList>> getTodoLists({required String userId}) async {
    final response = await _api.getTodoListsByUserId(userId: userId);
    return response.data?.toList() ?? const [];
  }

  @override
  Future<api.TodoList> getTodoListById({required String listId}) async {
    final response = await _api.getTodoListById(listId: listId);
    return response.data!;
  }

  @override
  Future<api.TodoList> createTodoList({
    required String title,
    required String description,
  }) async {
    final response = await _api.createTodoList(
      newTodoList: api.NewTodoList(
        (builder) => builder
          ..title = title
          ..description = description,
      ),
    );
    return response.data!;
  }

  @override
  Future<api.TodoList> updateTodoList({
    required String listId,
    required String title,
    required String description,
  }) async {
    final response = await _api.updateTodoList(
      listId: listId,
      updateTodoList: api.UpdateTodoList(
        (builder) => builder
          ..title = title
          ..description = description,
      ),
    );
    return response.data!;
  }

  @override
  Future<void> deleteTodoList({required String listId}) async {
    await _api.deleteTodoList(listId: listId);
  }

  @override
  Future<api.TodoList> setTodoListPin({
    required String listId,
    required bool pinned,
  }) async {
    final response = await _api.setTodoListPin(
      listId: listId,
      setTodoListPin: api.SetTodoListPin(
        (builder) => builder..pinned = pinned,
      ),
    );
    return response.data!;
  }

  @override
  Future<List<api.TodoItem>> getTodoItems({required String listId}) async {
    final response = await _api.getTodoItemsByListId(listId: listId);
    return response.data?.toList() ?? const [];
  }

  @override
  Future<api.TodoItem> createTodoItem({
    required String listId,
    required String title,
    required String description,
    required bool completed,
    required String position,
    DateTime? dueDate,
  }) async {
    final response = await _api.createTodoItem(
      listId: listId,
      newTodoItem: api.NewTodoItem(
        (builder) => builder
          ..listId = listId
          ..title = title
          ..description = description
          ..completed = completed
          ..position = position
          ..dueDate = _normalizeMessieDateTime(dueDate),
      ),
    );
    return response.data!;
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
    final response = await _api.updateTodoItem(
      listId: listId,
      itemId: itemId,
      updateTodoItem: api.UpdateTodoItem(
        (builder) => builder
          ..title = title
          ..description = description
          ..completed = completed
          ..position = position
          ..dueDate = _normalizeMessieDateTime(dueDate),
      ),
    );
    return response.data!;
  }

  @override
  Future<void> deleteTodoItem({
    required String listId,
    required String itemId,
  }) async {
    await _api.deleteTodoItem(listId: listId, itemId: itemId);
  }

  @override
  Future<List<api.CollaboratorDetail>> getCollaborators({
    required String listId,
  }) async {
    final response = await _api.getCollaborators(listId: listId);
    return response.data?.toList() ?? const [];
  }

  @override
  Future<void> addCollaborator({
    required String listId,
    required String userId,
  }) async {
    await _api.addCollaborator(
      listId: listId,
      newCollaborator: api.NewCollaborator(
        (builder) => builder..userId = userId,
      ),
    );
  }

  @override
  Future<void> removeCollaborator({
    required String listId,
    required String userId,
  }) async {
    await _api.removeCollaborator(listId: listId, userId: userId);
  }

  @override
  Future<api.User?> getUserByMatrixId({required String matrixId}) async {
    try {
      final response = await _api.getUserByMatrixId(matrixId: matrixId);
      return response.data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }
}

typedef MessieTodoSdkFactory =
    MessieTodoSdk Function({required String apiBaseUrl, required String jwt});

class MessieTodoService {
  MessieTodoService({MessieTodoSdkFactory? sdkFactory})
    : _sdkFactory = sdkFactory ?? GeneratedMessieTodoSdk.new;

  final MessieTodoSdkFactory _sdkFactory;
  final MessieErrorService _errorService = const MessieErrorService();

  Future<T> _wrapRequest<T>(
    String message,
    Future<T> Function(MessieTodoSdk sdk) callback, {
    required String apiBaseUrl,
    required String jwt,
  }) async {
    final sdk = _sdkFactory(apiBaseUrl: apiBaseUrl, jwt: jwt);
    final stopwatch = Stopwatch()..start();
    Logs().d('[messie/todo] start $message base=$apiBaseUrl');
    try {
      final result = await callback(sdk);
      Logs().d(
        '[messie/todo] ok $message elapsed=${stopwatch.elapsedMilliseconds}ms',
      );
      return result;
    } on DioException catch (error) {
      Logs().w(
        '[messie/todo] dio $message elapsed=${stopwatch.elapsedMilliseconds}ms '
        'type=${error.type.name}',
        error,
      );
      throw await _errorService.fromDio('messie/todo', message, error);
    } catch (error, stackTrace) {
      Logs().w(
        '[messie/todo] fail $message elapsed=${stopwatch.elapsedMilliseconds}ms',
        error,
      );
      throw await _errorService.fromGeneric(
        'messie/todo',
        message,
        error,
        stackTrace,
      );
    }
  }

  Future<List<MessieTodoList>> getTodoLists({
    required String apiBaseUrl,
    required String jwt,
    required String userId,
  }) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw MessieUserException(
        kind: MessieErrorKind.unauthorized,
        operation: 'Failed to load todos',
        userMessage: 'Your Messie session is incomplete. Please sign in again.',
      );
    }

    return _wrapRequest(
      'Failed to load todos',
      (sdk) async => (await sdk.getTodoLists(
        userId: normalizedUserId,
      )).map(MessieTodoList.fromApi).toList(),
      apiBaseUrl: apiBaseUrl,
      jwt: jwt,
    );
  }

  Future<MessieTodoList> getTodoListById({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
  }) async => _wrapRequest(
    'Failed to load todo list',
    (sdk) async =>
        MessieTodoList.fromApi(await sdk.getTodoListById(listId: listId)),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieTodoList> createTodoList({
    required String apiBaseUrl,
    required String jwt,
    required String title,
    required String description,
  }) async => _wrapRequest(
    'Failed to create todo list',
    (sdk) async => MessieTodoList.fromApi(
      await sdk.createTodoList(title: title, description: description),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieTodoList> updateTodoList({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
    required String title,
    required String description,
  }) async => _wrapRequest(
    'Failed to update todo list',
    (sdk) async => MessieTodoList.fromApi(
      await sdk.updateTodoList(
        listId: listId,
        title: title,
        description: description,
      ),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<void> deleteTodoList({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
  }) async => _wrapRequest(
    'Failed to delete todo list',
    (sdk) => sdk.deleteTodoList(listId: listId),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieTodoList> setTodoListPin({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
    required bool pinned,
  }) async => _wrapRequest(
    'Failed to update todo list pin',
    (sdk) async => MessieTodoList.fromApi(
      await sdk.setTodoListPin(listId: listId, pinned: pinned),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<List<MessieTodoItem>> getTodoItems({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
  }) async => _wrapRequest(
    'Failed to load todo items',
    (sdk) async => (await sdk.getTodoItems(
      listId: listId,
    )).map(MessieTodoItem.fromApi).toList(),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieTodoItem> createTodoItem({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
    required String title,
    required String description,
    required bool completed,
    required String position,
    DateTime? dueDate,
  }) async => _wrapRequest(
    'Failed to create todo item',
    (sdk) async => MessieTodoItem.fromApi(
      await sdk.createTodoItem(
        listId: listId,
        title: title,
        description: description,
        completed: completed,
        position: position,
        dueDate: _normalizeMessieDateTime(dueDate),
      ),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieTodoItem> updateTodoItem({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
    required String itemId,
    required String title,
    required String description,
    required bool completed,
    required String position,
    DateTime? dueDate,
  }) async => _wrapRequest(
    'Failed to update todo item',
    (sdk) async => MessieTodoItem.fromApi(
      await sdk.updateTodoItem(
        listId: listId,
        itemId: itemId,
        title: title,
        description: description,
        completed: completed,
        position: position,
        dueDate: _normalizeMessieDateTime(dueDate),
      ),
    ),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<void> deleteTodoItem({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
    required String itemId,
  }) async => _wrapRequest(
    'Failed to delete todo item',
    (sdk) => sdk.deleteTodoItem(listId: listId, itemId: itemId),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<void> repositionTodoItems({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
    required Map<String, String> positions,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: _normalizeMessieApiBaseUrl(apiBaseUrl),
        headers: {'Authorization': 'Bearer $jwt'},
      ),
    );
    final stopwatch = Stopwatch()..start();
    Logs().d('[messie/todo] start Failed to reposition todo items base=$apiBaseUrl');
    try {
      await dio.put(
        '/todolists/$listId/items/reposition',
        data: {
          'updates': [
            for (final entry in positions.entries)
              {'item_id': entry.key, 'position': entry.value},
          ],
        },
      );
      Logs().d(
        '[messie/todo] ok Failed to reposition todo items elapsed=${stopwatch.elapsedMilliseconds}ms',
      );
    } on DioException catch (error) {
      Logs().w(
        '[messie/todo] dio Failed to reposition todo items elapsed=${stopwatch.elapsedMilliseconds}ms type=${error.type.name}',
        error,
      );
      throw await _errorService.fromDio(
        'messie/todo',
        'Failed to reposition todo items',
        error,
      );
    } catch (error, stackTrace) {
      Logs().w(
        '[messie/todo] fail Failed to reposition todo items elapsed=${stopwatch.elapsedMilliseconds}ms',
        error,
      );
      throw await _errorService.fromGeneric(
        'messie/todo',
        'Failed to reposition todo items',
        error,
        stackTrace,
      );
    } finally {
      dio.close();
    }
  }

  Future<List<MessieTodoCollaborator>> getCollaborators({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
  }) async => _wrapRequest(
    'Failed to load collaborators',
    (sdk) async => (await sdk.getCollaborators(
      listId: listId,
    )).map(MessieTodoCollaborator.fromApi).toList(),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<void> addCollaborator({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
    required String userId,
  }) async => _wrapRequest(
    'Failed to add collaborator',
    (sdk) => sdk.addCollaborator(listId: listId, userId: userId),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<void> removeCollaborator({
    required String apiBaseUrl,
    required String jwt,
    required String listId,
    required String userId,
  }) async => _wrapRequest(
    'Failed to remove collaborator',
    (sdk) => sdk.removeCollaborator(listId: listId, userId: userId),
    apiBaseUrl: apiBaseUrl,
    jwt: jwt,
  );

  Future<MessieUser?> getUserByMatrixId({
    required String apiBaseUrl,
    required String jwt,
    required String matrixId,
  }) async {
    final sdk = _sdkFactory(apiBaseUrl: apiBaseUrl, jwt: jwt);
    try {
      final user = await sdk.getUserByMatrixId(matrixId: matrixId);
      if (user == null) return null;
      return MessieUser.fromApi(user);
    } on DioException catch (error) {
      throw await _errorService.fromDio(
        'messie/todo',
        'Failed to look up user',
        error,
      );
    }
  }
}
