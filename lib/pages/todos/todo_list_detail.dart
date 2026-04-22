import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../../services/backend_session_service.dart';
import '../../services/messie_todo_service.dart';
import '../../widgets/matrix.dart';
import 'todo_list_detail_view.dart';

class TodoListDetailPage extends StatefulWidget {
  const TodoListDetailPage({
    required this.listId,
    this.initialTitle,
    this.initialDescription,
    super.key,
  });

  final String listId;
  final String? initialTitle;
  final String? initialDescription;

  @override
  State<TodoListDetailPage> createState() => TodoListDetailPageController();
}

class TodoListDetailPageController extends State<TodoListDetailPage> {
  final BackendSessionService _sessionService = BackendSessionService();
  final MessieTodoService _todoService = MessieTodoService();
  Future<TodoListDetailData>? _loadFuture;

  Future<TodoListDetailData> get loadFuture => _loadFuture!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFuture ??= load(context);
  }

  @override
  void didUpdateWidget(covariant TodoListDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listId != widget.listId) {
      _loadFuture = load(context);
    }
  }

  void refresh() {
    setState(() {
      _loadFuture = load(context);
    });
  }

  Future<_TodoListSession> _session(BuildContext context) async {
    final matrix = Matrix.of(context);
    final session = await _sessionService.ensureSession(
      matrix.client,
      matrix.store,
    );
    return _TodoListSession(session.token);
  }

  Future<TodoListDetailData> load(BuildContext context) async {
    final session = await _session(context);
    final listFuture = _todoService.getTodoListById(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
    );
    final itemsFuture = _todoService.getTodoItems(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
    );
    final collaboratorsFuture = _todoService
        .getCollaborators(
          apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
          jwt: session.jwt,
          listId: widget.listId,
        )
        .then<(List<MessieTodoCollaborator>, Object?)>(
          (collaborators) => (collaborators, null),
        )
        .catchError(
          (error) => (const <MessieTodoCollaborator>[], error as Object),
        );

    final list = await listFuture;
    final items = await itemsFuture;
    final (collaborators, collaboratorsError) = await collaboratorsFuture;

    final sortedItems = items..sort((a, b) => a.position.compareTo(b.position));

    return TodoListDetailData(
      list: list,
      items: sortedItems,
      collaborators: collaborators,
      collaboratorsError: collaboratorsError,
    );
  }

  Future<void> createItem(
    BuildContext context, {
    required String title,
    String description = '',
    DateTime? dueDate,
    required List<MessieTodoItem> existingItems,
  }) async {
    final session = await _session(context);
    final position = existingItems.isEmpty
        ? _positionForIndex(0)
        : '${existingItems.last.position}~';
    await _todoService.createTodoItem(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
      title: title,
      description: description,
      completed: false,
      position: position,
      dueDate: dueDate,
    );
    refresh();
  }

  Future<void> updateItem(
    BuildContext context, {
    required MessieTodoItem item,
    String? title,
    String? description,
    bool? completed,
    String? position,
    DateTime? dueDate,
  }) async {
    final session = await _session(context);
    await _todoService.updateTodoItem(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
      itemId: item.id,
      title: title ?? item.title,
      description: description ?? item.description,
      completed: completed ?? item.completed,
      position: position ?? item.position,
      dueDate: dueDate ?? item.dueDate,
    );
    refresh();
  }

  Future<void> deleteItem(BuildContext context, String itemId) async {
    final session = await _session(context);
    await _todoService.deleteTodoItem(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
      itemId: itemId,
    );
    refresh();
  }

  Future<void> reorderItems(
    BuildContext context, {
    required List<MessieTodoItem> items,
    required int oldIndex,
    required int newIndex,
  }) async {
    if (oldIndex < 0 ||
        oldIndex >= items.length ||
        newIndex < 0 ||
        newIndex >= items.length ||
        oldIndex == newIndex) {
      return;
    }

    final reordered = [...items];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    for (var i = 0; i < reordered.length; i++) {
      final item = reordered[i];
      final nextPosition = _positionForIndex(i);
      if (item.position == nextPosition) continue;
      await updateItem(context, item: item, position: nextPosition);
    }
    refresh();
  }

  Future<void> updateList(
    BuildContext context, {
    required String title,
    required String description,
  }) async {
    final session = await _session(context);
    await _todoService.updateTodoList(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
      title: title,
      description: description,
    );
    refresh();
  }

  Future<void> deleteList(BuildContext context) async {
    final session = await _session(context);
    await _todoService.deleteTodoList(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
    );
  }

  Future<void> addCollaborator(
    BuildContext context,
    String userId, {
    bool refreshAfter = true,
  }) async {
    final session = await _session(context);
    await _todoService.addCollaborator(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
      userId: userId,
    );
    if (refreshAfter) refresh();
  }

  Future<MessieUser?> findMessieUserByMatrixId(
    BuildContext context,
    String matrixId,
  ) async {
    final session = await _session(context);
    return _todoService.getUserByMatrixId(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      matrixId: matrixId,
    );
  }

  Future<List<Profile>> searchMatrixUsers(
    BuildContext context,
    String searchTerm,
  ) async {
    final result = await Matrix.of(
      context,
    ).client.searchUserDirectory(searchTerm, limit: 10);
    final profiles = List<Profile>.from(result.results);

    if (searchTerm.isValidMatrixId &&
        searchTerm.sigil == '@' &&
        !profiles.any((profile) => profile.userId == searchTerm)) {
      profiles.add(Profile(userId: searchTerm));
    }

    return profiles;
  }

  Future<void> removeCollaborator(
    BuildContext context,
    String userId, {
    bool refreshAfter = true,
  }) async {
    final session = await _session(context);
    await _todoService.removeCollaborator(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
      userId: userId,
    );
    if (refreshAfter) refresh();
  }

  String _positionForIndex(int index) =>
      ((index + 1) * 1000).toString().padLeft(12, '0');

  @override
  Widget build(BuildContext context) => TodoListDetailPageView(this);
}

class TodoListDetailData {
  TodoListDetailData({
    required this.list,
    required this.items,
    required this.collaborators,
    this.collaboratorsError,
  });

  final MessieTodoList list;
  final List<MessieTodoItem> items;
  final List<MessieTodoCollaborator> collaborators;
  final Object? collaboratorsError;
}

class _TodoListSession {
  _TodoListSession(this.jwt);

  final String jwt;
}
