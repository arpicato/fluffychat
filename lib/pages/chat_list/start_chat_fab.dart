// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/todos/create_todo_list.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_modal_action_popup.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _CreateAction { chat, todoList }

class StartChatFab extends StatelessWidget {
  final VoidCallback? onCreateTodoList;

  const StartChatFab({super.key, this.onCreateTodoList});

  Future<_CreateAction?> _showDesktopMenu(BuildContext context) async {
    final button = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return null;
    final buttonRect = Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    );
    return showMenu<_CreateAction>(
      context: context,
      position: RelativeRect.fromRect(buttonRect, Offset.zero & overlay.size),
      items: const [
        PopupMenuItem(
          value: _CreateAction.chat,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.chat_bubble_outline),
            title: Text('New chat'),
          ),
        ),
        PopupMenuItem(
          value: _CreateAction.todoList,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.checklist_rtl_outlined),
            title: Text('New list'),
          ),
        ),
      ],
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    final l10n = L10n.of(context);
    final useAnchoredMenu = PlatformInfos.isWeb || PlatformInfos.isDesktop;
    _CreateAction? action;
    if (useAnchoredMenu) {
      // ignore: use_build_context_synchronously
      action = await _showDesktopMenu(context);
    } else {
      // ignore: use_build_context_synchronously
      action = await showModalActionPopup<_CreateAction>(
        context: context,
        useRootNavigator: false,
        title: 'Create',
        cancelLabel: l10n.cancel,
        actions: [
          AdaptiveModalAction(
            label: l10n.newChat,
            value: _CreateAction.chat,
            icon: const Icon(Icons.chat_bubble_outline),
            isDefaultAction: true,
          ),
          AdaptiveModalAction(
            label: 'New list',
            value: _CreateAction.todoList,
            icon: const Icon(Icons.checklist_rtl_outlined),
          ),
        ],
      );
    }
    if (!context.mounted || action == null) return;
    switch (action) {
      case _CreateAction.chat:
        context.go('/rooms/newprivatechat');
      case _CreateAction.todoList:
        if (!context.mounted) return;
        await showCreateTodoListFlow(context, onCreated: onCreateTodoList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'start_chat_fab',
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      onPressed: () => _onPressed(context),
      tooltip: 'Create',
      child: const Icon(Icons.edit_square),
    );
  }
}
