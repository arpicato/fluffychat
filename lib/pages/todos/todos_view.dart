import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/services/backend_session_service.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'todos.dart';

class TodosPageView extends StatelessWidget {
  TodosPageView(this.controller, {super.key});

  final TodosPageController controller;
  final MessieTodoService _todoService = MessieTodoService();

  Future<List<MessieTodoList>> _load(BuildContext context) async {
    final matrix = Matrix.of(context);
    final session = await BackendSessionService().ensureSession(
      matrix.client,
      matrix.store,
    );
    return _todoService.getTodoLists(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.token,
      userId: session.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
        centerTitle: FluffyThemes.isColumnMode(context),
      ),
      body: FutureBuilder<List<MessieTodoList>>(
        future: _load(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return MaxWidthBody(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load todos from Messie.',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: controller.refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final todoLists = snapshot.requireData;
          return MaxWidthBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (todoLists.isEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.checklist_outlined),
                      title: const Text('No todo lists yet'),
                      subtitle: Text(
                        'This account does not have any todo lists yet. Create one in Messie and then refresh this page.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: controller.refresh,
                        child: const Text('Refresh'),
                      ),
                    ),
                  ),
                ...todoLists.map(
                  (todo) => Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      onTap: () => context.go(
                        '/rooms/todos/${todo.id}',
                        extra: <String, Object?>{
                          'title': todo.title,
                          'description': todo.description,
                        },
                      ),
                      leading: const Icon(Icons.checklist_rtl_outlined),
                      title: Text(
                        todo.title.isEmpty ? 'Untitled list' : todo.title,
                      ),
                      subtitle: Text(
                        todo.description.isEmpty
                            ? 'No description'
                            : todo.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatTimestamp(todo.updatedAt ?? todo.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
