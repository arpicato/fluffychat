import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../services/backend_session_service.dart';
import '../../services/messie_todo_service.dart';
import '../../services/messie_workspace_refresh.dart';
import '../../widgets/matrix.dart';
import 'todo_list_detail_logic.dart';
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
  TodoListDetailData? _data;
  bool showCompletedItems = false;

  Future<TodoListDetailData> get loadFuture => _loadFuture!;
  TodoListDetailData? get currentData => _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFuture ??= load(context);
  }

  @override
  void didUpdateWidget(covariant TodoListDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listId != widget.listId) {
      showCompletedItems = false;
      _loadFuture = load(context);
    }
  }

  void refresh() {
    setState(() {
      _loadFuture = load(context);
    });
  }

  void setShowCompletedItems(bool value) {
    if (showCompletedItems == value) return;
    setState(() => showCompletedItems = value);
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

    final data = TodoListDetailData(
      list: list,
      items: sortedItems,
      collaborators: collaborators,
      collaboratorsError: collaboratorsError,
    );
    if (mounted) {
      setState(() => _data = data);
    }
    return data;
  }

  Future<void> createItem(
    BuildContext context, {
    required String title,
    String description = '',
    DateTime? dueDate,
    required List<MessieTodoItem> existingItems,
  }) async {
    final session = await _session(context);
    final insertPlan = buildNewTodoItemInsertPlan(existingItems);
    if (insertPlan.updatedPositions.isNotEmpty) {
      for (final item in existingItems) {
        final updatedPosition = insertPlan.updatedPositions[item.id];
        if (updatedPosition != null) {
          await _todoService.updateTodoItem(
            apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
            jwt: session.jwt,
            listId: widget.listId,
            itemId: item.id,
            title: item.title,
            description: item.description,
            completed: item.completed,
            position: updatedPosition,
            dueDate: item.dueDate,
          );
        }
      }
    }
    final createdItem = await _todoService.createTodoItem(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
      title: title,
      description: description,
      completed: false,
      position: insertPlan.position,
      dueDate: dueDate,
    );
    final currentData = _data;
    if (currentData == null) return;
    final normalizedItems = currentData.items.map((item) {
      final updatedPosition = insertPlan.updatedPositions[item.id];
      return updatedPosition == null ? item : _copyItem(item, position: updatedPosition);
    }).toList();
    _setData(
      currentData.copyWith(
        items: _sortedItems([...normalizedItems, createdItem]),
      ),
    );
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
    final previousData = _data;
    if (previousData == null) return;
    final optimisticItem = _copyItem(
      item,
      title: title,
      description: description,
      completed: completed,
      position: position,
      dueDate: dueDate,
    );
    _setData(previousData.replaceItem(optimisticItem));
    final session = await _session(context);
    try {
      final updatedItem = await _todoService.updateTodoItem(
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
      _setData(previousData.replaceItem(updatedItem));
    } catch (error) {
      _setData(previousData);
      rethrow;
    }
  }

  Future<void> deleteItem(BuildContext context, String itemId) async {
    final previousData = _data;
    if (previousData == null) return;
    _setData(
      previousData.copyWith(
        items: previousData.items.where((item) => item.id != itemId).toList(),
      ),
    );
    final session = await _session(context);
    try {
      await _todoService.deleteTodoItem(
        apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
        jwt: session.jwt,
        listId: widget.listId,
        itemId: itemId,
      );
    } catch (error) {
      _setData(previousData);
      rethrow;
    }
  }

  Future<void> reorderItems(
    BuildContext context, {
    required List<MessieTodoItem> items,
    required TodoItemGroup group,
    required int oldIndex,
    required int newIndex,
  }) async {
    final previousData = _data;
    if (previousData == null) return;
    final reorderPlan = buildTodoReorderPlan(
      items,
      group: group,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    if (reorderPlan.updatedPositions.isEmpty) return;
    final optimisticItems = _sortedItems([
      for (final item in reorderPlan.items)
        if (reorderPlan.updatedPositions.containsKey(item.id))
          _copyItem(item, position: reorderPlan.updatedPositions[item.id])
        else
          item,
    ]);
    _setData(previousData.copyWith(items: optimisticItems));
    final session = await _session(context);
    try {
      for (final item in reorderPlan.items) {
        final updatedPosition = reorderPlan.updatedPositions[item.id];
        if (updatedPosition == null) continue;
        await _todoService.updateTodoItem(
          apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
          jwt: session.jwt,
          listId: widget.listId,
          itemId: item.id,
          title: item.title,
          description: item.description,
          completed: item.completed,
          position: updatedPosition,
          dueDate: item.dueDate,
        );
      }
      refresh();
    } catch (error) {
      _setData(previousData);
      rethrow;
    }
  }

  Future<void> reorderItemById(
    BuildContext context, {
    required String itemId,
    required bool moveDown,
  }) async {
    final data = _data;
    if (data == null) return;
    final groupedItems = groupTodoItems(data.items);
    for (final group in TodoItemGroup.values) {
      final items = switch (group) {
        TodoItemGroup.active => groupedItems.activeItems,
        TodoItemGroup.completed => groupedItems.completedItems,
      };
      final oldIndex = items.indexWhere((item) => item.id == itemId);
      if (oldIndex == -1) continue;
      final newIndex = moveDown ? oldIndex + 1 : oldIndex - 1;
      if (newIndex < 0 || newIndex >= items.length) return;
      await reorderItems(
        context,
        items: items,
        group: group,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
      return;
    }
  }

  Future<void> updateList(
    BuildContext context, {
    required String title,
    required String description,
  }) async {
    final previousData = _data;
    if (previousData == null) return;
    _setData(
      previousData.copyWith(
        list: _copyList(
          previousData.list,
          title: title,
          description: description,
        ),
      ),
    );
    final session = await _session(context);
    try {
      final updatedList = await _todoService.updateTodoList(
        apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
        jwt: session.jwt,
        listId: widget.listId,
        title: title,
        description: description,
      );
      _setData(previousData.copyWith(list: updatedList));
    } catch (error) {
      _setData(previousData);
      rethrow;
    }
  }

  Future<void> deleteList(BuildContext context) async {
    final session = await _session(context);
    await _todoService.deleteTodoList(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.jwt,
      listId: widget.listId,
    );
    MessieWorkspaceRefresh.instance.bump();
    if (context.mounted) {
      context.go('/rooms');
    }
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

  void _setData(TodoListDetailData data) {
    if (!mounted) return;
    setState(() => _data = data);
  }

  List<MessieTodoItem> _sortedItems(List<MessieTodoItem> items) =>
      [...items]..sort((a, b) => a.position.compareTo(b.position));

  MessieTodoItem _copyItem(
    MessieTodoItem item, {
    String? title,
    String? description,
    bool? completed,
    String? position,
    DateTime? dueDate,
  }) => MessieTodoItem(
    id: item.id,
    listId: item.listId,
    title: title ?? item.title,
    description: description ?? item.description,
    completed: completed ?? item.completed,
    position: position ?? item.position,
    dueDate: dueDate ?? item.dueDate,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
  );

  MessieTodoList _copyList(
    MessieTodoList list, {
    String? title,
    String? description,
  }) => MessieTodoList(
    id: list.id,
    ownerId: list.ownerId,
    title: title ?? list.title,
    description: description ?? list.description,
    pinned: list.pinned,
    lastActivityAt: list.lastActivityAt,
    createdAt: list.createdAt,
    updatedAt: list.updatedAt,
  );

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

  TodoListDetailData copyWith({
    MessieTodoList? list,
    List<MessieTodoItem>? items,
    List<MessieTodoCollaborator>? collaborators,
    Object? collaboratorsError = _todoListDetailDataSentinel,
  }) => TodoListDetailData(
    list: list ?? this.list,
    items: items ?? this.items,
    collaborators: collaborators ?? this.collaborators,
    collaboratorsError:
        identical(collaboratorsError, _todoListDetailDataSentinel)
        ? this.collaboratorsError
        : collaboratorsError,
  );

  TodoListDetailData replaceItem(MessieTodoItem updatedItem) => copyWith(
    items: [
      for (final item in items)
        if (item.id == updatedItem.id) updatedItem else item,
    ],
  );
}

const _todoListDetailDataSentinel = Object();

class _TodoListSession {
  _TodoListSession(this.jwt);

  final String jwt;
}
