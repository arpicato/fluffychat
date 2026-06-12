import 'dart:async';
import 'dart:math' as math;

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/services/messie_error_presentation.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../widgets/matrix.dart';
import 'todo_list_detail.dart';
import 'todo_list_detail_logic.dart';

void _showTodoError(BuildContext context, String message, Object error) {
  final text = messieUserMessage(error, fallback: message);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(text)));
}

const double _todoItemDialogTargetWidth = 520;
const double _todoItemDialogTargetHeight = 560;
const int _todoItemTitleMaxLength = 120;
const int _todoItemDescriptionMaxLength = 2000;
const int _todoItemListTitleMaxLines = 1;
const int _todoItemListSubtitleMaxLines = 2;
const double _todoLeadingSlotWidth = 40;

String _compactTodoRowText(String value) =>
    value.replaceAll(RegExp(r'\s+'), ' ').trim();

Widget _todoLeadingSlot({required Widget child}) => SizedBox(
  width: _todoLeadingSlotWidth,
  child: Center(child: child),
);

class TodoListDetailPageView extends StatefulWidget {
  const TodoListDetailPageView(this.controller, {super.key});

  final TodoListDetailPageController controller;

  @override
  State<TodoListDetailPageView> createState() => _TodoListDetailPageViewState();
}

class _TodoListDetailPageViewState extends State<TodoListDetailPageView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  TodoListDetailPageController get controller => widget.controller;

  void _navigateBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/rooms');
  }

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
      _showTodoError(context, 'Could not update todo list', error);
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
      _showTodoError(context, 'Could not delete todo list', error);
    }
  }

  Future<void> _showCollaboratorsDialog(
    BuildContext pageContext,
    TodoListDetailData data,
  ) async {
    final changed = await showDialog<bool>(
      context: pageContext,
      builder: (dialogContext) => _CollaboratorsDialog(
        controller: controller,
        data: data,
        pageContext: pageContext,
      ),
    );
    if (changed == true && pageContext.mounted) {
      controller.refresh();
    }
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
      builder: (dialogContext) {
        final availableSize = MediaQuery.sizeOf(dialogContext);
        final dialogWidth = math.min(
          _todoItemDialogTargetWidth,
          availableSize.width - 48,
        );
        final dialogHeight = math.min(
          _todoItemDialogTargetHeight,
          availableSize.height * 0.8,
        );
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
              Navigator.of(dialogContext).pop(true);
            },
          },
          child: AlertDialog(
            title: const Text('Add todo item'),
            content: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      maxLength: _todoItemTitleMaxLength,
                      minLines: 1,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      minLines: 4,
                      maxLines: 8,
                      maxLength: _todoItemDescriptionMaxLength,
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
              ),
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
      },
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
      _showTodoError(context, 'Could not create todo item', error);
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
        builder: (context, setState) {
          final availableSize = MediaQuery.sizeOf(dialogContext);
          final dialogWidth = math.min(
            _todoItemDialogTargetWidth,
            availableSize.width - 48,
          );
          final dialogHeight = math.min(
            _todoItemDialogTargetHeight,
            availableSize.height * 0.8,
          );
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
                Navigator.of(dialogContext).pop(true);
              },
            },
            child: AlertDialog(
              title: const Text('Edit todo item'),
              content: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        maxLength: _todoItemTitleMaxLength,
                        minLines: 1,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        minLines: 4,
                        maxLines: 8,
                        maxLength: _todoItemDescriptionMaxLength,
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
                                      dueDateController.text =
                                          _formatDateInput(picked);
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
                ),
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
        },
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
      _showTodoError(context, 'Could not update todo item', error);
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
      _showTodoError(context, 'Could not delete todo item', error);
    }
  }

  Future<void> _confirmDeleteItem(BuildContext context, MessieTodoItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete todo item?'),
        content: Text(
          item.title.trim().isEmpty
              ? 'This will permanently delete the selected item.'
              : 'This will permanently delete "${item.title.trim()}".',
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
    if (confirmed == true && context.mounted) {
      await _deleteItem(context, item);
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
      _showTodoError(context, 'Could not update todo item', error);
    }
  }

  Future<void> _moveItem(
    BuildContext context,
    TodoListDetailData data,
    TodoItemGroup group,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      await controller.reorderItems(
        context,
        items: data.items,
        group: group,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
    } catch (error) {
      if (!context.mounted) return;
      _showTodoError(context, 'Could not reorder todo item', error);
    }
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
    future: controller.loadFuture,
    builder: (context, snapshot) {
      final theme = Theme.of(context);
      final currentData = controller.currentData;

      if (snapshot.connectionState != ConnectionState.done &&
          currentData == null) {
        final title = controller.widget.initialTitle?.trim().isNotEmpty == true
            ? controller.widget.initialTitle!
            : 'Todo list';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            automaticallyImplyLeading: false,
            leading: FluffyThemes.isColumnMode(context)
                ? null
                : BackButton(onPressed: () => _navigateBack(context)),
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
            automaticallyImplyLeading: false,
            leading: FluffyThemes.isColumnMode(context)
                ? null
                : BackButton(onPressed: () => _navigateBack(context)),
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
                      messieUserMessage(
                        snapshot.error,
                        fallback: 'Please try again in a moment.',
                      ),
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

      final data = currentData ?? snapshot.requireData;
      final groupedItems = groupTodoItems(data.items);
      final shortcutTargets = <TodoShortcutTarget>[
        const TodoShortcutTarget.addRow(),
        ...groupedItems.activeItems.map(TodoShortcutTarget.item),
        if (controller.showCompletedItems)
          ...groupedItems.completedItems.map(TodoShortcutTarget.item),
      ];
      return TodoListShortcutScope(
        targets: shortcutTargets,
        scrollController: _scrollController,
        onCreateItem: () {
          unawaited(_createItem(context, data));
        },
        onEditItem: (item) => _editItem(context, item),
        onToggleItem: (item, completed) => _toggleItem(context, item, completed),
        onDeleteItem: (item) => _confirmDeleteItem(context, item),
        onReorderItem: (item, moveDown) => controller.reorderItemById(
          context,
          itemId: item.id,
          moveDown: moveDown,
        ),
        builder: (context, bindings) => Scaffold(
          appBar: AppBar(
            title: Text(data.list.title.isEmpty ? 'Todo list' : data.list.title),
            automaticallyImplyLeading: false,
            leading: FluffyThemes.isColumnMode(context)
                ? null
                : BackButton(onPressed: () => _navigateBack(context)),
            centerTitle: FluffyThemes.isColumnMode(context),
            actions: [
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
            withScrolling: false,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                                avatar: const Icon(
                                  Icons.group_outlined,
                                  size: 18,
                                ),
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
                ),
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: TodoShortcutFocusItem(
                      bindings: bindings,
                      targetId: 'add-row',
                      child: (context, focused) => TodoListAddItemRow(
                        focused: focused,
                        onTap: () => _createItem(context, data),
                      ),
                    ),
                  ),
                ),
                if (data.items.isEmpty)
                  SliverToBoxAdapter(
                    child: Card(
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
                  ),
                if (data.items.isNotEmpty)
                  SliverToBoxAdapter(
                    child: TodoListItemsSection(
                      groupedItems: groupedItems,
                      showCompletedItems: controller.showCompletedItems,
                      formatTimestamp: _formatTimestamp,
                      onShowCompletedItemsChanged:
                          controller.setShowCompletedItems,
                      onToggleItem: (item, completed) =>
                          _toggleItem(context, item, completed),
                      onMoveItem: (group, oldIndex, newIndex) =>
                          _moveItem(context, data, group, oldIndex, newIndex),
                      onEditItem: (item) => _editItem(context, item),
                      onDeleteItem: (item) => _deleteItem(context, item),
                      bindings: bindings,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class TodoListItemsSection extends StatelessWidget {
  const TodoListItemsSection({
    required this.groupedItems,
    required this.showCompletedItems,
    required this.formatTimestamp,
    required this.onShowCompletedItemsChanged,
    required this.onToggleItem,
    required this.onMoveItem,
    required this.onEditItem,
    required this.onDeleteItem,
    this.bindings,
    super.key,
  });

  final GroupedTodoItems groupedItems;
  final bool showCompletedItems;
  final String Function(DateTime? value) formatTimestamp;
  final ValueChanged<bool> onShowCompletedItemsChanged;
  final Future<void> Function(MessieTodoItem item, bool completed) onToggleItem;
  final Future<void> Function(TodoItemGroup group, int oldIndex, int newIndex)
  onMoveItem;
  final Future<void> Function(MessieTodoItem item) onEditItem;
  final Future<void> Function(MessieTodoItem item) onDeleteItem;
  final TodoShortcutBindings? bindings;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (groupedItems.activeItems.isNotEmpty)
        _TodoItemReorderableList(
          key: const ValueKey('todo-items-active'),
          group: TodoItemGroup.active,
          items: groupedItems.activeItems,
          formatTimestamp: formatTimestamp,
          onToggleItem: onToggleItem,
          onMoveItem: onMoveItem,
          onEditItem: onEditItem,
          onDeleteItem: onDeleteItem,
          bindings: bindings,
        ),
      if (groupedItems.completedItems.isNotEmpty)
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.checklist_outlined),
            title: Text('Done (${groupedItems.completedItems.length})'),
            trailing: Icon(
              showCompletedItems ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () => onShowCompletedItemsChanged(!showCompletedItems),
          ),
        ),
      if (showCompletedItems && groupedItems.completedItems.isNotEmpty)
        _TodoItemReorderableList(
          key: const ValueKey('todo-items-completed'),
          group: TodoItemGroup.completed,
          items: groupedItems.completedItems,
          formatTimestamp: formatTimestamp,
          onToggleItem: onToggleItem,
          onMoveItem: onMoveItem,
          onEditItem: onEditItem,
          onDeleteItem: onDeleteItem,
          bindings: bindings,
        ),
    ],
  );
}

class TodoListAddItemRow extends StatelessWidget {
  const TodoListAddItemRow({
    required this.onTap,
    this.focused = false,
    super.key,
  });

  final VoidCallback onTap;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: focused ? theme.colorScheme.secondaryContainer : null,
      child: ListTile(
        key: const ValueKey('todo-add-item-row'),
        onTap: onTap,
        leading: _todoLeadingSlot(
          child: Icon(
            Icons.add_task_outlined,
            size: 28,
          ),
        ),
        title: Text('Add todo item', style: theme.textTheme.titleMedium),
        subtitle: const Text('Create a new item in this list.'),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: false,
      ),
    );
  }
}

enum TodoShortcutTargetType { addRow, item }

class TodoShortcutTarget {
  const TodoShortcutTarget.addRow() : type = TodoShortcutTargetType.addRow, item = null;

  const TodoShortcutTarget.item(this.item) : type = TodoShortcutTargetType.item;

  final TodoShortcutTargetType type;
  final MessieTodoItem? item;

  String get targetId => switch (type) {
    TodoShortcutTargetType.addRow => 'add-row',
    TodoShortcutTargetType.item => item!.id,
  };
}

class TodoShortcutBindings {
  TodoShortcutBindings._(this._state);

  final _TodoListShortcutScopeState _state;

  String? get focusedTargetId => _state.focusedTargetId;

  FocusNode registerFocusNode(String targetId) => _state.registerFocusNode(targetId);

  GlobalKey registerScrollTargetKey(String targetId) =>
      _state.registerScrollTargetKey(targetId);

  void unregisterScrollTargetKey(String targetId, GlobalKey key) =>
      _state.unregisterScrollTargetKey(targetId, key);

  void unregisterFocusNode(String targetId, FocusNode focusNode) =>
      _state.unregisterFocusNode(targetId, focusNode);

  void reportFocusedTarget(String targetId) => _state.reportFocusedTarget(targetId);

  KeyEventResult handleKey(FocusNode node, KeyEvent event) =>
      _state.handleKey(node, event);
}

class TodoListShortcutScope extends StatefulWidget {
  const TodoListShortcutScope({
    required this.targets,
    required this.scrollController,
    required this.onCreateItem,
    required this.onEditItem,
    required this.onToggleItem,
    required this.onDeleteItem,
    required this.onReorderItem,
    required this.builder,
    super.key,
  });

  final List<TodoShortcutTarget> targets;
  final ScrollController scrollController;
  final VoidCallback onCreateItem;
  final Future<void> Function(MessieTodoItem item) onEditItem;
  final Future<void> Function(MessieTodoItem item, bool completed) onToggleItem;
  final Future<void> Function(MessieTodoItem item) onDeleteItem;
  final Future<void> Function(MessieTodoItem item, bool moveDown) onReorderItem;
  final Widget Function(BuildContext context, TodoShortcutBindings bindings)
  builder;

  @override
  State<TodoListShortcutScope> createState() => _TodoListShortcutScopeState();
}

class _TodoListShortcutScopeState extends State<TodoListShortcutScope> {
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, GlobalKey> _scrollTargetKeys = {};
  String? _focusedTargetId = 'add-row';
  static const int _maxFocusRetryFrames = 8;

  TodoShortcutBindings get _bindings => TodoShortcutBindings._(this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestFocus(_focusedTargetId);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TodoListShortcutScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targets.isEmpty) {
      _focusedTargetId = null;
      return;
    }
    final targetIds = widget.targets.map((target) => target.targetId).toSet();
    if (_focusedTargetId == null || !targetIds.contains(_focusedTargetId)) {
      final currentIndex = _currentFocusedIndex;
      final clampedIndex = currentIndex.clamp(0, widget.targets.length - 1);
      _focusedTargetId = widget.targets[clampedIndex].targetId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestFocus(_focusedTargetId);
    });
  }

  bool get _hasTargets => widget.targets.isNotEmpty;

  int get _currentFocusedIndex {
    if (!_hasTargets) return 0;
    final index = widget.targets.indexWhere(
      (target) => target.targetId == _focusedTargetId,
    );
    return index < 0 ? 0 : index;
  }

  TodoShortcutTarget? get _focusedTarget => _hasTargets
      ? widget.targets[_currentFocusedIndex]
      : null;

  String? get focusedTargetId => _focusedTargetId;

  FocusNode registerFocusNode(String targetId) =>
      _focusNodes[targetId] ??= FocusNode(skipTraversal: true);

  GlobalKey registerScrollTargetKey(String targetId) =>
      _scrollTargetKeys[targetId] ??= GlobalKey();

  void unregisterScrollTargetKey(String targetId, GlobalKey key) {
    final registered = _scrollTargetKeys[targetId];
    if (identical(registered, key)) {
      _scrollTargetKeys.remove(targetId);
    }
  }

  void unregisterFocusNode(String targetId, FocusNode focusNode) {
    final registered = _focusNodes[targetId];
    if (identical(registered, focusNode)) {
      _focusNodes.remove(targetId);
    }
    focusNode.dispose();
  }

  void reportFocusedTarget(String targetId) {
    if (_focusedTargetId == targetId) return;
    setState(() {
      _focusedTargetId = targetId;
    });
  }

  void _requestFocus(String? targetId) {
    if (targetId == null) return;
    final node = _focusNodes[targetId];
    if (node != null && node.canRequestFocus) {
      node.requestFocus();
    }
  }

  void _ensureTargetVisible(String targetId) {
    final targetContext = _scrollTargetKeys[targetId]?.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(targetContext, duration: Duration.zero, alignment: 0.5);
  }

  void _scrollTowardTarget(int delta) {
    if (!widget.scrollController.hasClients) return;
    final position = widget.scrollController.position;
    final viewportStep = math.max(position.viewportDimension * 0.8, 96);
    final nextOffset = (position.pixels + (delta * viewportStep)).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (nextOffset == position.pixels) return;
    widget.scrollController.jumpTo(nextOffset);
  }

  void _requestFocusWhenAvailable(
    String targetId, {
    required int delta,
    int attemptsRemaining = _maxFocusRetryFrames,
  }) {
    if (!mounted) return;
    final node = _focusNodes[targetId];
    if (node != null && node.canRequestFocus) {
      _ensureTargetVisible(targetId);
      node.requestFocus();
      return;
    }
    if (attemptsRemaining <= 0) return;
    _scrollTowardTarget(delta);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestFocusWhenAvailable(
        targetId,
        delta: delta,
        attemptsRemaining: attemptsRemaining - 1,
      );
    });
  }

  void _moveFocus(int delta) {
    if (!_hasTargets) return;
    final newIndex = (_currentFocusedIndex + delta).clamp(0, widget.targets.length - 1);
    final targetId = widget.targets[newIndex].targetId;
    setState(() {
      _focusedTargetId = targetId;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestFocusWhenAvailable(targetId, delta: delta);
    });
  }

  Future<void> _toggleFocusedItem() async {
    final item = _focusedTarget?.item;
    if (item == null) return;
    await widget.onToggleItem(item, !item.completed);
  }

  Future<void> _editFocusedItem() async {
    final item = _focusedTarget?.item;
    if (item == null) return;
    await widget.onEditItem(item);
  }

  Future<void> _deleteFocusedItem() async {
    final item = _focusedTarget?.item;
    if (item == null) return;
    await widget.onDeleteItem(item);
  }

  Future<void> _reorderFocusedItem(bool moveDown) async {
    final item = _focusedTarget?.item;
    if (item == null) return;
    _focusedTargetId = item.id;
    await widget.onReorderItem(item, moveDown);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestFocus(item.id);
    });
  }

  KeyEventResult handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final altPressed = HardwareKeyboard.instance.isAltPressed;
    switch (key) {
      case LogicalKeyboardKey.keyN:
        widget.onCreateItem();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.keyE:
        _editFocusedItem();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        _toggleFocusedItem();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.delete:
      case LogicalKeyboardKey.backspace:
        _deleteFocusedItem();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        if (altPressed) {
          _reorderFocusedItem(false);
        } else {
          _moveFocus(-1);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        if (altPressed) {
          _reorderFocusedItem(true);
        } else {
          _moveFocus(1);
        }
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _bindings);
}

class TodoShortcutFocusItem extends StatefulWidget {
  const TodoShortcutFocusItem({
    required this.bindings,
    required this.targetId,
    required this.child,
    super.key,
  });

  final TodoShortcutBindings bindings;
  final String targetId;
  final Widget Function(BuildContext context, bool focused) child;

  @override
  State<TodoShortcutFocusItem> createState() => _TodoShortcutFocusItemState();
}

class _TodoShortcutFocusItemState extends State<TodoShortcutFocusItem> {
  late final FocusNode _focusNode;
  late bool _isFocused;
  late final GlobalKey _scrollTargetKey;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.bindings.registerFocusNode(widget.targetId);
    _scrollTargetKey = widget.bindings.registerScrollTargetKey(widget.targetId);
    _isFocused = widget.bindings.focusedTargetId == widget.targetId;
  }

  @override
  void dispose() {
    widget.bindings.unregisterScrollTargetKey(widget.targetId, _scrollTargetKey);
    widget.bindings.unregisterFocusNode(widget.targetId, _focusNode);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TodoShortcutFocusItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldBeFocused = widget.bindings.focusedTargetId == widget.targetId;
    if (shouldBeFocused != _isFocused) {
      _isFocused = shouldBeFocused;
    }
  }

  @override
  Widget build(BuildContext context) => Focus(
    autofocus: widget.bindings.focusedTargetId == widget.targetId,
    focusNode: _focusNode,
    onKeyEvent: widget.bindings.handleKey,
    onFocusChange: (focused) {
      if (focused != _isFocused) {
        setState(() => _isFocused = focused);
        if (focused) {
          widget.bindings.reportFocusedTarget(widget.targetId);
        }
      }
    },
    child: KeyedSubtree(
      key: _scrollTargetKey,
      child: widget.child(context, _isFocused),
    ),
  );
}

class _TodoItemReorderableList extends StatelessWidget {
  const _TodoItemReorderableList({
    super.key,
    required this.group,
    required this.items,
    required this.formatTimestamp,
    required this.onToggleItem,
    required this.onMoveItem,
    required this.onEditItem,
    required this.onDeleteItem,
    this.bindings,
  });

  final TodoItemGroup group;
  final List<MessieTodoItem> items;
  final String Function(DateTime? value) formatTimestamp;
  final Future<void> Function(MessieTodoItem item, bool completed) onToggleItem;
  final Future<void> Function(TodoItemGroup group, int oldIndex, int newIndex)
  onMoveItem;
  final Future<void> Function(MessieTodoItem item) onEditItem;
  final Future<void> Function(MessieTodoItem item) onDeleteItem;
  final TodoShortcutBindings? bindings;

  @override
  Widget build(BuildContext context) => ReorderableListView.builder(
    key: key,
    shrinkWrap: true,
    primary: false,
    physics: const NeverScrollableScrollPhysics(),
    buildDefaultDragHandles: false,
    itemCount: items.length,
    onReorder: (oldIndex, newIndex) {
      final adjustedNewIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
      onMoveItem(group, oldIndex, adjustedNewIndex);
    },
    itemBuilder: (context, index) => _TodoItemCard(
      key: ValueKey(items[index].id),
      item: items[index],
      index: index,
      formatTimestamp: formatTimestamp,
      onToggleItem: onToggleItem,
      onEditItem: onEditItem,
      onDeleteItem: onDeleteItem,
      bindings: bindings,
    ),
  );
}

class _TodoItemCard extends StatelessWidget {
  const _TodoItemCard({
    required this.index,
    required this.item,
    required this.formatTimestamp,
    required this.onToggleItem,
    required this.onEditItem,
    required this.onDeleteItem,
    this.bindings,
    super.key,
  });

  final int index;
  final MessieTodoItem item;
  final String Function(DateTime? value) formatTimestamp;
  final Future<void> Function(MessieTodoItem item, bool completed) onToggleItem;
  final Future<void> Function(MessieTodoItem item) onEditItem;
  final Future<void> Function(MessieTodoItem item) onDeleteItem;
  final TodoShortcutBindings? bindings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = _compactTodoRowText(item.title);
    final descriptionText = _compactTodoRowText(item.description);
    final dueDateText =
        item.dueDate == null ? null : 'Due ${formatTimestamp(item.dueDate)}';
    final subtitleParts = <String>[
      if (descriptionText.isNotEmpty) descriptionText,
      ...?dueDateText == null ? null : [dueDateText],
    ];
    final subtitleText = subtitleParts.join(' • ');

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => onEditItem(item),
        leading: _todoLeadingSlot(
          child: Checkbox(
            value: item.completed,
            onChanged: (value) {
              if (value == null) return;
              onToggleItem(item, value);
            },
          ),
        ),
        title: Text(
          titleText.isEmpty ? 'Untitled item' : titleText,
          maxLines: _todoItemListTitleMaxLines,
          overflow: TextOverflow.ellipsis,
          style: item.completed
              ? theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                )
              : theme.textTheme.titleMedium,
        ),
        subtitle: subtitleText.isEmpty
            ? null
            : Text(
                subtitleText,
                maxLines: _todoItemListSubtitleMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
        isThreeLine: false,
        trailing: Wrap(
          spacing: 4,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Tooltip(
                message: 'Reorder',
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.drag_handle),
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEditItem(item);
                  case 'delete':
                    onDeleteItem(item);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit item')),
                PopupMenuItem(value: 'delete', child: Text('Delete item')),
              ],
            ),
          ],
        ),
      ),
    );

    if (bindings == null) {
      return card;
    }

    return TodoShortcutFocusItem(
      bindings: bindings!,
      targetId: item.id,
      child: (context, focused) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: focused ? theme.colorScheme.secondaryContainer : null,
        child: card.child,
      ),
    );
  }
}

class _CollaboratorsDialog extends StatefulWidget {
  const _CollaboratorsDialog({
    required this.controller,
    required this.data,
    required this.pageContext,
  });

  final TodoListDetailPageController controller;
  final TodoListDetailData data;
  final BuildContext pageContext;

  @override
  State<_CollaboratorsDialog> createState() => _CollaboratorsDialogState();
}

class _CollaboratorsDialogState extends State<_CollaboratorsDialog> {
  static const _searchResultsSectionHeight = 180.0;

  late final TextEditingController _searchController;
  Future<List<Profile>>? _searchFuture;
  Timer? _searchCooldown;
  bool _resolving = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchCooldown?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearch(String value) {
    _searchCooldown?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchFuture = null;
        _statusMessage = null;
      });
      return;
    }
    _searchCooldown = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
        _searchFuture = widget.controller.searchMatrixUsers(context, trimmed);
      });
    });
  }

  Future<void> _removeCollaborator(String collaboratorId) async {
    try {
      await widget.controller.removeCollaborator(
        context,
        collaboratorId,
        refreshAfter: false,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showTodoError(context, 'Could not remove collaborator', error);
    }
  }

  Future<void> _addCollaborator(Profile profile) async {
    setState(() {
      _resolving = true;
      _statusMessage = null;
    });
    try {
      final messieUser = await widget.controller.findMessieUserByMatrixId(
        context,
        profile.userId,
      );
      if (!mounted) return;

      if (messieUser == null) {
        setState(() {
          _statusMessage =
              '${profile.userId} exists in Matrix, but does not have a Messie account yet. Invites are not available here yet.';
        });
        return;
      }

      final alreadyCollaborator =
          messieUser.id == widget.data.list.ownerId ||
          widget.data.collaborators.any(
            (collaborator) => collaborator.collaboratorId == messieUser.id,
          );
      if (alreadyCollaborator) {
        setState(() {
          _statusMessage = 'This user already has access to the list.';
        });
        return;
      }

      if (!mounted) return;
      await widget.controller.addCollaborator(
        context,
        messieUser.id,
        refreshAfter: false,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!widget.pageContext.mounted) return;
      _showTodoError(widget.pageContext, 'Could not add collaborator', error);
    } finally {
      if (mounted) {
        setState(() => _resolving = false);
      }
    }
  }

  MessieTodoCollaborator? _findCollaboratorByMatrixId(String matrixId) {
    for (final collaborator in widget.data.collaborators) {
      if (collaborator.matrixId == matrixId) {
        return collaborator;
      }
    }
    return null;
  }

  String _matrixLocalpart(String matrixId) =>
      matrixId.localpart ?? matrixId.replaceFirst('@', '').split(':').first;

  String _collaboratorUsername(MessieTodoCollaborator collaborator) {
    final username = collaborator.username.trim();
    if (username.isNotEmpty) return username;
    return _matrixLocalpart(collaborator.matrixId);
  }

  String _collaboratorTitle(MessieTodoCollaborator collaborator) {
    final displayName = collaborator.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return _collaboratorUsername(collaborator);
  }

  String _rowTitle({
    Profile? profile,
    MessieTodoCollaborator? collaborator,
    required String matrixId,
  }) {
    final displayName = profile?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    if (collaborator != null) {
      return _collaboratorTitle(collaborator);
    }
    return _matrixLocalpart(matrixId);
  }

  String _rowUsername({
    required String matrixId,
    MessieTodoCollaborator? collaborator,
  }) {
    if (collaborator != null) {
      return _collaboratorUsername(collaborator);
    }
    return _matrixLocalpart(matrixId);
  }

  Widget _buildCollaboratorRow({
    required String title,
    required String username,
    required String matrixId,
    required IconData actionIcon,
    required String actionTooltip,
    required VoidCallback onAction,
    Uri? avatarUrl,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Avatar(
      name: title,
      mxContent: avatarUrl,
      presenceUserId: matrixId,
    ),
    title: Text(title),
    subtitle: Text('$username\n$matrixId'),
    isThreeLine: true,
    trailing: IconButton(
      icon: Icon(actionIcon),
      tooltip: actionTooltip,
      onPressed: onAction,
    ),
    onTap: onAction,
  );

  Widget _buildCollaboratorsList() {
    if (widget.data.collaborators.isEmpty) {
      return const Align(
        alignment: Alignment.topLeft,
        child: Text('No collaborators yet.'),
      );
    }

    return ListView(
      itemExtent: 84,
      children: widget.data.collaborators
          .map(
            (collaborator) => FutureBuilder<Profile>(
              future: Matrix.of(
                context,
              ).client.getProfileFromUserId(collaborator.matrixId),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                return _buildCollaboratorRow(
                  title: _rowTitle(
                    profile: profile,
                    collaborator: collaborator,
                    matrixId: collaborator.matrixId,
                  ),
                  username: _rowUsername(
                    matrixId: collaborator.matrixId,
                    collaborator: collaborator,
                  ),
                  matrixId: collaborator.matrixId,
                  avatarUrl: profile?.avatarUrl,
                  actionIcon: Icons.person_remove_outlined,
                  actionTooltip: 'Remove collaborator',
                  onAction: () =>
                      _removeCollaborator(collaborator.collaboratorId),
                );
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_resolving) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_searchFuture == null) {
      return const Align(
        alignment: Alignment.topLeft,
        child: Text('Search Matrix users to add them as collaborators.'),
      );
    }

    return FutureBuilder<List<Profile>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                messieUserMessage(
                  snapshot.error,
                  fallback: 'Unable to search for collaborators right now.',
                ),
              ),
            ),
          );
        }

        final profiles = snapshot.data ?? const <Profile>[];
        if (profiles.isEmpty) {
          return const Align(
            alignment: Alignment.topLeft,
            child: Text('No users found.'),
          );
        }

        return ListView.builder(
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            final collaborator = _findCollaboratorByMatrixId(profile.userId);
            final alreadyCollaborator = collaborator != null;
            return _buildCollaboratorRow(
              title: _rowTitle(
                profile: profile,
                collaborator: collaborator,
                matrixId: profile.userId,
              ),
              username: _rowUsername(
                matrixId: profile.userId,
                collaborator: collaborator,
              ),
              matrixId: profile.userId,
              avatarUrl: profile.avatarUrl,
              actionIcon: alreadyCollaborator
                  ? Icons.person_remove_outlined
                  : Icons.person_add_outlined,
              actionTooltip: alreadyCollaborator
                  ? 'Remove collaborator'
                  : 'Add collaborator',
              onAction: alreadyCollaborator
                  ? () => _removeCollaborator(collaborator.collaboratorId)
                  : () => _addCollaborator(profile),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Collaborators'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search by Matrix user',
              hintText: '@alice:messie.localhost',
              prefixIcon: Icon(Icons.search_outlined),
            ),
            onChanged: _updateSearch,
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: _searchResultsSectionHeight,
            child: _searchFuture == null
                ? _buildCollaboratorsList()
                : _buildSearchResults(context),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Close'),
      ),
    ],
  );
}
