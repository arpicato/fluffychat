import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/services/backend_session_service.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

import 'todo_list_detail.dart';

class TodoListDetailPageView extends StatelessWidget {
  TodoListDetailPageView(this.controller, {super.key});

  final TodoListDetailPageController controller;
  final BackendSessionService _sessionService = BackendSessionService();
  final MessieTodoService _todoService = MessieTodoService();

  Future<_TodoListDetailData> _load(BuildContext context) async {
    final matrix = Matrix.of(context);
    final session = await _sessionService.ensureSession(
      matrix.client,
      matrix.store,
    );
    final items = await _todoService.getTodoItems(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.token,
      listId: controller.widget.listId,
    );
    return _TodoListDetailData(session: session, items: items);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = controller.widget.initialTitle?.trim().isNotEmpty == true
        ? controller.widget.initialTitle!
        : 'Todo list';
    final description = controller.widget.initialDescription?.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
        centerTitle: FluffyThemes.isColumnMode(context),
      ),
      body: FutureBuilder<_TodoListDetailData>(
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
                        'Could not load todo list.',
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

          final data = snapshot.requireData;
          return MaxWidthBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: const Icon(Icons.checklist_outlined),
                  title: Text(title),
                  subtitle: Text(
                    [
                      if (description != null && description.isNotEmpty)
                        description,
                      'items: ${data.items.length}',
                    ].join('\n'),
                  ),
                ),
                if (data.items.isEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.playlist_add_check_outlined),
                      title: const Text('No items yet'),
                      subtitle: const Text(
                        'This list exists, but it does not have any todo items yet.',
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: controller.refresh,
                        child: const Text('Refresh'),
                      ),
                    ),
                  ),
                ...data.items.map(
                  (item) => CheckboxListTile(
                    value: item.completed,
                    onChanged: null,
                    secondary: const Icon(Icons.drag_indicator_outlined),
                    title: Text(
                      item.title.isEmpty ? 'Untitled item' : item.title,
                    ),
                    subtitle: Text(
                      [
                        if (item.description.isNotEmpty) item.description,
                        if (item.dueDate != null)
                          'Due ${_formatTimestamp(item.dueDate)}',
                      ].join('\n'),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
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

class _TodoListDetailData {
  _TodoListDetailData({required this.session, required this.items});

  final BackendSession session;
  final List<MessieTodoItem> items;
}
