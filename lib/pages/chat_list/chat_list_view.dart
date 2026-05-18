import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_list/start_chat_fab.dart';
import 'package:fluffychat/utils/keyboard/intents.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../widgets/matrix.dart';

import 'chat_list_body.dart';

class ChatListView extends StatelessWidget {
  final ChatListController controller;

  const ChatListView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final showRail =
        FluffyThemes.isColumnMode(context) ||
        AppSettings.displayNavigationRail.value;
    return Actions(
      actions: <Type, Action<Intent>>{
        SearchIntent: CallbackAction<SearchIntent>(
          onInvoke: (_) {
            controller.startSearch();
            return null;
          },
        ),
        NewChatIntent: CallbackAction<NewChatIntent>(
          onInvoke: (_) {
            context.go('/rooms/newprivatechat');
            return null;
          },
        ),
        SettingsIntent: CallbackAction<SettingsIntent>(
          onInvoke: (_) {
            context.go('/rooms/settings');
            return null;
          },
        ),
      },
      child: PopScope(
      canPop: !controller.isSearchMode && controller.activeSpaceId == null,
      onPopInvokedWithResult: (pop, _) {
        if (pop) return;
        if (controller.activeSpaceId != null) {
          controller.clearActiveSpace();
          return;
        }
        if (controller.isSearchMode) {
          controller.cancelSearch();
          return;
        }
      },
      child: Row(
        children: [
          if (showRail) ...[
            SpacesNavigationRail(
              activeSpaceId: controller.activeSpaceId,
              onGoToChats: () {
                controller.clearActiveSpace();
                context.go('/rooms');
              },
              onGoToCalendar: () {
                controller.clearActiveSpace();
                context.go('/rooms/calendar');
              },
              onGoToSpaceId: controller.setActiveSpace,
            ),
            Container(color: Theme.of(context).dividerColor, width: 1),
          ],
          Expanded(
            child: GestureDetector(
              onTap: FocusManager.instance.primaryFocus?.unfocus,
              excludeFromSemantics: true,
              behavior: HitTestBehavior.translucent,
              child: Scaffold(
                body: ChatListViewBody(controller),
                floatingActionButton:
                    !controller.isSearchMode &&
                        controller.activeSpaceId == null &&
                        !FluffyThemes.isColumnMode(context)
                    ? const StartChatFab()
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
// ignore: unused_element
class _MobileWorkspaceDrawer extends StatelessWidget {
  const _MobileWorkspaceDrawer({required this.controller});

  final ChatListController controller;

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final theme = Theme.of(context);
    final activePath = GoRouterState.of(context).uri.path;
    final spaces = client.rooms.where((room) => room.isSpace).toList();

    void navigateTo(String path) {
      Navigator.of(context).pop();
      controller.clearActiveSpace();
      context.go(path);
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.forum_outlined),
              title: Text(L10n.of(context).chats),
              selected:
                  controller.activeSpaceId == null &&
                  !activePath.startsWith('/rooms/calendar') &&
                  !activePath.startsWith('/rooms/settings'),
              onTap: () => navigateTo('/rooms'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Calendar'),
              selected: activePath.startsWith('/rooms/calendar'),
              onTap: () => navigateTo('/rooms/calendar'),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(L10n.of(context).settings),
              selected: activePath.startsWith('/rooms/settings'),
              onTap: () => navigateTo('/rooms/settings'),
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Spaces',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ...spaces.map((space) {
              final displayName = space.getLocalizedDisplayname(
                MatrixLocals(L10n.of(context)),
              );
              return ListTile(
                leading: Avatar(
                  mxContent: space.avatar,
                  name: displayName,
                  size: 20,
                ),
                title: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: controller.activeSpaceId == space.id,
                onTap: () {
                  Navigator.of(context).pop();
                  controller.setActiveSpace(space.id);
                },
              );
            }),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(L10n.of(context).createNewSpace),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/rooms/newspace');
              },
            ),
          ],
        ),
      ),
    );
  }
}
