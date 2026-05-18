import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluffychat/utils/keyboard/intents.dart';
import 'package:fluffychat/utils/keyboard/keyboard_navigation.dart';

/// Top-level shortcut bindings for the app.
/// Wrap the app shell with this widget to enable keyboard navigation.
///
/// Actions are handled by the nearest Actions widget in the tree that
/// registers handlers for these intents — typically in ChatList and Chat pages.
class AppShortcuts extends StatelessWidget {
  const AppShortcuts({super.key, required this.child});

  final Widget child;

  static final bool _isMac = defaultTargetPlatform == TargetPlatform.macOS;

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

        // Chat list navigation (Alt+Arrow to avoid conflict with text input)
        const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
            const ChatListFocusUpIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
            const ChatListFocusDownIntent(),
        const SingleActivator(LogicalKeyboardKey.enter, alt: true):
            const ChatListOpenFocusedIntent(),

        // Message list navigation — Escape enters message focus mode,
        // then plain arrows/keys work. These use Alt modifier so they
        // never conflict with text input.
        const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true, shift: true):
            const MessageFocusUpIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true, shift: true):
            const MessageFocusDownIntent(),

        // Reply/Edit: Alt+R / Alt+E (won't conflict with typing)
        const SingleActivator(LogicalKeyboardKey.keyR, alt: true):
            const MessageReplyIntent(),
        const SingleActivator(LogicalKeyboardKey.keyE, alt: true):
            const MessageEditIntent(),
      },
      child: _GoBackActionHandler(child: child),
    );
  }
}

/// Handles the GoBack/Escape intent with keyboard navigation awareness.
/// If message list is focused, deselects first. Otherwise delegates to
/// normal back navigation.
class _GoBackActionHandler extends StatelessWidget {
  const _GoBackActionHandler({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        GoBackIntent: CallbackAction<GoBackIntent>(
          onInvoke: (_) {
            final keyboardNav = KeyboardNavigation.maybeOf(context);
            if (keyboardNav != null) {
              if (keyboardNav.focusArea == KeyboardFocusArea.messageList) {
                keyboardNav.resetMessageFocus();
                return null;
              }
              if (keyboardNav.hasChatListFocus) {
                keyboardNav.resetChatListFocus();
                return null;
              }
            }
            // Let the default PopScope/back navigation handle it
            Navigator.of(context).maybePop();
            return null;
          },
        ),
      },
      child: child,
    );
  }
}
