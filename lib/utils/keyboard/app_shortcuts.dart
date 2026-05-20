import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluffychat/utils/keyboard/shortcut_dispatcher.dart';
import 'package:fluffychat/utils/keyboard/shortcut_resolver.dart';
import 'package:fluffychat/widgets/fluffy_chat_app.dart';

class AppShortcuts extends StatefulWidget {
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
  State<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends State<AppShortcuts> {
  static final ShortcutResolver _resolver = ShortcutResolver();

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // If Esc and a dialog/modal is showing (focus is inside a route overlay
    // that is not a page route), skip our handler entirely so the dialog
    // can close itself.
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      final primaryFocus = FocusManager.instance.primaryFocus;
      if (primaryFocus != null) {
        final focusContext = primaryFocus.context;
        if (focusContext != null) {
          final route = ModalRoute.of(focusContext);
          if (route != null && route is! PageRoute) {
            return KeyEventResult.ignored;
          }
        }
      }
    }

    final dispatcher = ShortcutDispatcher.instance;
    final chat = dispatcher.chatHandler;
    final chatList = dispatcher.chatListHandler;
    final path = FluffyChatApp.router.routeInformationProvider.value.uri.path;
    final primaryPressed =
        AppShortcuts._isMac
            ? HardwareKeyboard.instance.isMetaPressed
            : HardwareKeyboard.instance.isControlPressed;
    final altPressed = HardwareKeyboard.instance.isAltPressed;
    final shiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final hasOpenChat =
        path.startsWith('/rooms/') &&
        !path.startsWith('/rooms/settings') &&
        !path.startsWith('/rooms/archive/') &&
        path.split('/').length >= 3;

    debugPrint(
      '[kb/raw] key=${event.logicalKey.keyLabel} '
      'logical=${event.logicalKey.debugName} '
      'ctrl=${HardwareKeyboard.instance.isControlPressed} '
      'meta=${HardwareKeyboard.instance.isMetaPressed} '
      'alt=${HardwareKeyboard.instance.isAltPressed} '
      'shift=${HardwareKeyboard.instance.isShiftPressed} '
      'focus=${FocusManager.instance.primaryFocus?.debugLabel}',
    );

    final handled = _resolver.resolve(
      keyState: ShortcutKeyState(
        key: event.logicalKey,
        primaryPressed: primaryPressed,
        altPressed: altPressed,
        shiftPressed: shiftPressed,
      ),
      context: ShortcutContext(hasOpenChat: hasOpenChat),
      chat: chat,
      chatList: chatList,
    );

    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: widget.child,
    );
  }
}
