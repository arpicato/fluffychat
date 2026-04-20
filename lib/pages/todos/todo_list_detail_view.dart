import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'todo_list_detail.dart';

class TodoListDetailPageView extends StatelessWidget {
  const TodoListDetailPageView(this.controller, {super.key});

  final TodoListDetailPageController controller;

  Future<void> _editList(BuildContext context, MessieTodoList list) async {
    final titleController = TextEditingController(text: list.title);
    final descriptionController = TextEditingController(text: list.description);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit todo list'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    titleController.dispose();
    descriptionController.dispose();

    if (confirmed != true || title.isEmpty || !context.mounted) {
      return;
    }

    try {
      await controller.updateList(
        context,
        title: title,
        description: description,
      );
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Could not update todo list', error);
    }
  }

  Future<void> _deleteList(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete todo list?'),
        content: const Text(
          'This will permanently delete the list and all of its items.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await controller.deleteList(context);
      if (!context.mounted) return;
      context.go('/rooms');
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Could not delete todo list', error);
    }
  }

  Future<void> _showCollaboratorsDialog(
    BuildContext context,
    TodoListDetailData data,
  ) async {
    final userIdController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Collaborators'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.collaborators.isEmpty)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No collaborators yet.'),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: data.collaborators
                          .map(
                            (collaborator) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(collaborator.username),
                              subtitle: Text(collaborator.collaboratorId),
                              trailing: IconButton(
                                icon: const Icon(Icons.person_remove_outlined),
                                tooltip: 'Remove collaborator',
                                onPressed: () async {
                                  try {
                                    await controller.removeCollaborator(
                                      dialogContext,
                                      collaborator.collaboratorId,
                                    );
                                    if (!dialogContext.mounted) return;
                                    Navigator.of(dialogContext).pop();
                                  } catch (error) {
                                    if (!dialogContext.mounted) return;
                                    _showError(
                                      dialogContext,
                                      'Could not remove collaborator',
                                      error,
                                    );
                                  }
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    labelText: 'Collaborator user ID',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                final userId = userIdController.text.trim();
                if (userId.isEmpty) return;
                try {
                  await controller.addCollaborator(dialogContext, userId);
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                } catch (error) {
                  if (!dialogContext.mounted) return;
                  _showError(
                    dialogContext,
                    'Could not add collaborator',
                    error,
                  );
                  setState(() {});
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createItem(
    BuildContext context,
    TodoListDetailData data,
  ) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final dueDateController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add todo item'),
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
            const SizedBox(height: 12),
            TextField(
              controller: dueDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Due date',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: dialogContext,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  dueDateController.text = _formatDateInput(picked);
                }
              },
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
            child: const Text('Add'),
          ),
        ],
      ),
    );

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final dueDate = _parseDateInput(dueDateController.text);
    titleController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();

    if (confirmed != true || title.isEmpty || !context.mounted) {
      return;
    }

    try {
      await controller.createItem(
        context,
        title: title,
        description: description,
        dueDate: dueDate,
        existingItems: data.items,
      );
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Could not create todo item', error);
    }
  }

  Future<void> _editItem(BuildContext context, MessieTodoItem item) async {
    final titleController = TextEditingController(text: item.title);
    final descriptionController = TextEditingController(text: item.description);
    final dueDateController = TextEditingController(
      text: _formatDateInput(item.dueDate),
    );
    var completed = item.completed;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit todo item'),
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
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Completed'),
                value: completed,
                onChanged: (value) => setState(() => completed = value),
              ),
              TextField(
                controller: dueDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Due date',
                  suffixIcon: Wrap(
                    spacing: 4,
                    children: [
                      if (dueDateController.text.isNotEmpty)
                        IconButton(
                          onPressed: () => setState(() {
                            dueDateController.text = '';
                          }),
                          icon: const Icon(Icons.clear),
                        ),
                      IconButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: item.dueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              dueDateController.text = _formatDateInput(picked);
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ],
                  ),
                ),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final dueDate = _parseDateInput(dueDateController.text);
    titleController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();

    if (confirmed != true || title.isEmpty || !context.mounted) {
      return;
    }

    try {
      await controller.updateItem(
        context,
        item: item,
        title: title,
        description: description,
        completed: completed,
        dueDate: dueDate,
      );
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Could not update todo item', error);
    }
  }

  Future<void> _deleteItem(BuildContext context, MessieTodoItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete todo item?'),
        content: Text(
          'Delete "${item.title.isEmpty ? 'Untitled item' : item.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await controller.deleteItem(context, item.id);
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Could not delete todo item', error);
    }
  }

  Future<void> _toggleItem(
    BuildContext context,
    MessieTodoItem item,
    bool completed,
  ) async {
    try {
      await controller.updateItem(context, item: item, completed: completed);
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Could not update todo item', error);
    }
  }

  Future<void> _moveItem(
    BuildContext context,
    TodoListDetailData data,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      await controller.reorderItems(
        context,
        items: data.items,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Could not reorder todo item', error);
    }
  }

  void _showError(BuildContext context, String message, Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$message: $error')));
  }

  static String _formatDateInput(DateTime? value) {
    if (value == null) return '';
    final utc = value.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }

  static DateTime? _parseDateInput(String value) {
    if (value.isEmpty) return null;
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime.utc(year, month, day);
  }

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    final utc = dateTime.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<TodoListDetailData>(
    future: controller.load(context),
    builder: (context, snapshot) {
      final theme = Theme.of(context);

      if (snapshot.connectionState != ConnectionState.done) {
        final title = controller.widget.initialTitle?.trim().isNotEmpty == true
            ? controller.widget.initialTitle!
            : 'Todo list';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
            centerTitle: FluffyThemes.isColumnMode(context),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (snapshot.hasError) {
        final title = controller.widget.initialTitle?.trim().isNotEmpty == true
            ? controller.widget.initialTitle!
            : 'Todo list';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
            centerTitle: FluffyThemes.isColumnMode(context),
          ),
          body: MaxWidthBody(
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
          ),
        );
      }

      final data = snapshot.requireData;
      return Scaffold(
        appBar: AppBar(
          title: Text(data.list.title.isEmpty ? 'Todo list' : data.list.title),
          automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
          centerTitle: FluffyThemes.isColumnMode(context),
          actions: [
            IconButton(
              onPressed: () => _createItem(context, data),
              icon: const Icon(Icons.add),
              tooltip: 'Add item',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editList(context, data.list);
                  case 'collaborators':
                    _showCollaboratorsDialog(context, data);
                  case 'delete':
                    _deleteList(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit list')),
                PopupMenuItem(
                  value: 'collaborators',
                  child: Text('Manage collaborators'),
                ),
                PopupMenuItem(value: 'delete', child: Text('Delete list')),
              ],
            ),
          ],
        ),
        body: MaxWidthBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.list.title.isEmpty
                            ? 'Untitled list'
                            : data.list.title,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (data.list.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          data.list.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(
                              Icons.format_list_bulleted,
                              size: 18,
                            ),
                            label: Text('${data.items.length} items'),
                          ),
                          Chip(
                            avatar: const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                            ),
                            label: Text(
                              '${data.items.where((item) => item.completed).length} completed',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(Icons.group_outlined, size: 18),
                            label: Text(
                              '${data.collaborators.length} collaborator${data.collaborators.length == 1 ? '' : 's'}',
                            ),
                          ),
                        ],
                      ),
                      if (data.collaboratorsError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Collaborators are temporarily unavailable. You can still work with the list and items.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.add_task_outlined),
                  title: const Text('Add todo item'),
                  subtitle: const Text('Create a new item in this list.'),
                  trailing: FilledButton.tonal(
                    onPressed: () => _createItem(context, data),
                    child: const Text('Add'),
                  ),
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
                      onPressed: () => _createItem(context, data),
                      child: const Text('Add first item'),
                    ),
                  ),
                ),
              ...data.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final descriptionParts = <String>[
                  if (item.description.isNotEmpty) item.description,
                  if (item.dueDate != null)
                    'Due ${_formatTimestamp(item.dueDate)}',
                ];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.completed,
                      onChanged: (value) {
                        if (value == null) return;
                        _toggleItem(context, item, value);
                      },
                    ),
                    title: Text(
                      item.title.isEmpty ? 'Untitled item' : item.title,
                      style: item.completed
                          ? theme.textTheme.titleMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                            )
                          : theme.textTheme.titleMedium,
                    ),
                    subtitle: descriptionParts.isEmpty
                        ? const Text('No description')
                        : Text(descriptionParts.join('\n')),
                    isThreeLine: descriptionParts.length > 1,
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          onPressed: index == 0
                              ? null
                              : () =>
                                    _moveItem(context, data, index, index - 1),
                          icon: const Icon(Icons.arrow_upward_outlined),
                          tooltip: 'Move up',
                        ),
                        IconButton(
                          onPressed: index == data.items.length - 1
                              ? null
                              : () =>
                                    _moveItem(context, data, index, index + 1),
                          icon: const Icon(Icons.arrow_downward_outlined),
                          tooltip: 'Move down',
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _editItem(context, item);
                              case 'delete':
                                _deleteItem(context, item);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit item'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete item'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
