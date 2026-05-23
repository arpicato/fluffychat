// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileWorkspaceBottomBar extends StatelessWidget {
  const MobileWorkspaceBottomBar({
    required this.currentPath,
    required this.child,
    super.key,
  });

  final String currentPath;
  final Widget child;

  bool get _showBottomBar =>
      currentPath == '/rooms' ||
      currentPath.startsWith('/rooms/calendar') ||
      currentPath == '/rooms/todos' ||
      currentPath.startsWith('/rooms/todos/') ||
      currentPath == '/rooms/settings' ||
      currentPath.startsWith('/rooms/settings/');

  int get _selectedIndex {
    if (currentPath.startsWith('/rooms/calendar') ||
        currentPath == '/rooms/todos' ||
        currentPath.startsWith('/rooms/todos/')) {
      return 1;
    }
    if (currentPath.startsWith('/rooms/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (FluffyThemes.isColumnMode(context) || !_showBottomBar) {
      return child;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/rooms');
              break;
            case 1:
              context.go('/rooms/calendar');
              break;
            case 2:
              context.go('/rooms/settings');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.forum_outlined),
            selectedIcon: const Icon(Icons.forum),
            label: L10n.of(context).chats,
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: L10n.of(context).settings,
          ),
        ],
      ),
    );
  }
}
