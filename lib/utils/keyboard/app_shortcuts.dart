import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluffychat/utils/keyboard/intents.dart';

/// Top-level shortcut bindings for the app.
/// Wrap the app shell with this widget to enable keyboard navigation.
///
/// Actions are handled by the nearest Actions widget in the tree that
/// registers handlers for these intents — typically in ChatList and Chat pages.
class AppShortcuts extends StatelessWidget {
  const AppShortcuts({super.key, required this.child});

  final Widget child;

  static final bool _isMac =
      defaultTargetPlatform == TargetPlatform.macOS;

  /// The modifier key for shortcuts (Cmd on macOS, Ctrl elsewhere).
  static SingleActivator _ctrl(LogicalKeyboardKey key) => SingleActivator(
        key,
        meta: _isMac,
        control: !_isMac,
      );

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // Global navigation
        _ctrl(LogicalKeyboardKey.keyK): const SearchIntent(),
        _ctrl(LogicalKeyboardKey.keyN): const NewChatIntent(),
        _ctrl(LogicalKeyboardKey.comma): const SettingsIntent(),
        const SingleActivator(LogicalKeyboardKey.escape): const GoBackIntent(),

        // Chat list navigation
        const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
            const ChatListFocusUpIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
            const ChatListFocusDownIntent(),
        const SingleActivator(LogicalKeyboardKey.enter, alt: true):
            const ChatListOpenFocusedIntent(),

        // Message list navigation (active when message list is focused)
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            const MessageFocusUpIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            const MessageFocusDownIntent(),
        const SingleActivator(LogicalKeyboardKey.keyR):
            const MessageReplyIntent(),
        const SingleActivator(LogicalKeyboardKey.keyE):
            const MessageEditIntent(),
      },
      child: child,
    );
  }
}
