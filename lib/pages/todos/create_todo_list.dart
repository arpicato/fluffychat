import 'package:fluffychat/services/backend_session_service.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showCreateTodoListFlow(
  BuildContext context, {
  VoidCallback? onCreated,
}) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final created = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Create todo list'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Create'),
        ),
      ],
    ),
  );

  final title = titleController.text.trim();
  final description = descriptionController.text.trim();
  titleController.dispose();
  descriptionController.dispose();

  if (created != true || title.isEmpty || !context.mounted) {
    return;
  }

  try {
    final matrix = Matrix.of(context);
    final session = await BackendSessionService().ensureSession(
      matrix.client,
      matrix.store,
    );
    final todoList = await MessieTodoService().createTodoList(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.token,
      title: title,
      description: description,
    );
    if (!context.mounted) return;
    onCreated?.call();
    context.go(
      '/rooms/todos/${todoList.id}',
      extra: <String, Object?>{
        'title': todoList.title,
        'description': todoList.description,
      },
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not create todo list: $error')));
  }
}
