import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:fluffychat/widgets/hover_builder.dart';
import 'package:flutter/material.dart';

import '../../config/themes.dart';

class ChatListTodoItem extends StatelessWidget {
  const ChatListTodoItem({
    required this.todoList,
    required this.onTap,
    this.active = false,
    super.key,
  });

  final MessieTodoList todoList;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = active
        ? theme.colorScheme.secondaryContainer
        : null;
    final description = todoList.description.trim();
    final timestamp = todoList.updatedAt ?? todoList.createdAt;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        clipBehavior: Clip.hardEdge,
        color: backgroundColor,
        child: HoverBuilder(
          builder: (context, hovered) => ListTile(
            visualDensity: const VisualDensity(vertical: -0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            onTap: onTap,
            leading: AnimatedScale(
              duration: FluffyThemes.animationDuration,
              curve: FluffyThemes.animationCurve,
              scale: hovered ? 1.1 : 1.0,
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.tertiaryContainer,
                foregroundColor: theme.colorScheme.onTertiaryContainer,
                child: const Icon(Icons.checklist_rtl_outlined),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    todoList.title.isEmpty ? 'Untitled list' : todoList.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                if (timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      timestamp.toLocal().localizedTimeShort(context),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              description.isEmpty ? 'Messie todo list' : description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
