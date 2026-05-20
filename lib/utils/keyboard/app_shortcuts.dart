import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluffychat/utils/keyboard/shortcut_dispatcher.dart';
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
  bool _isPrimaryModifierPressed() =>
      AppShortcuts._isMac
          ? HardwareKeyboard.instance.isMetaPressed
          : HardwareKeyboard.instance.isControlPressed;

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final dispatcher = ShortcutDispatcher.instance;
    final chat = dispatcher.chatHandler;
    final chatList = dispatcher.chatListHandler;
    final key = event.logicalKey;
    final path = FluffyChatApp.router.routeInformationProvider.value.uri.path;
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

    if (_isPrimaryModifierPressed() && key == LogicalKeyboardKey.keyK) {
      return (chatList?.triggerSearch() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.escape) {
      if (chat?.handleEscape() == true) return KeyEventResult.handled;
      if (chatList?.handleEscape() == true) return KeyEventResult.handled;
      return KeyEventResult.ignored;
    }

    if (!HardwareKeyboard.instance.isAltPressed &&
        !HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.enter) {
      return (chatList?.openFocused() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isAltPressed &&
        !HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.enter) {
      return (chatList?.openFocused() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isAltPressed &&
        !HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.keyR) {
      return (chat?.replyFocusedMessage() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isAltPressed &&
        !HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.keyE) {
      return (chat?.editFocusedMessage() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isAltPressed &&
        HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.arrowUp) {
      return (chat?.messageFocusUp() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isAltPressed &&
        HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.arrowDown) {
      return (chat?.messageFocusDown() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isAltPressed &&
        !HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.arrowUp) {
      return (chatList?.focusUp() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isAltPressed &&
        !HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.arrowDown) {
      return (chatList?.focusDown() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (!HardwareKeyboard.instance.isAltPressed &&
        !HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.arrowUp) {
      if (!hasOpenChat) {
        return (chatList?.focusUp() ?? false)
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      }
      if (chat != null && (!chat.inputHasFocus || chat.composerCursorOnFirstLine)) {
        return chat.messageFocusUp()
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      }
    }

    if (!HardwareKeyboard.instance.isAltPressed &&
        !HardwareKeyboard.instance.isShiftPressed &&
        key == LogicalKeyboardKey.arrowDown) {
      if (!hasOpenChat) {
        return (chatList?.focusDown() ?? false)
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      }
      if (chat?.messageFocusActive == true) {
        return (chat?.messageFocusDown() ?? false)
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      }
    }

    return KeyEventResult.ignored;
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
