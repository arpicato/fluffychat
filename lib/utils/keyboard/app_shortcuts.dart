import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluffychat/utils/keyboard/shortcut_dispatcher.dart';
import 'package:fluffychat/utils/keyboard/shortcut_registry.dart';
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
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final dispatcher = ShortcutDispatcher.instance;
    final registry = AppShortcutRegistry.instance;
    final chat = dispatcher.chatHandler;
    final chatList = dispatcher.chatListHandler;
    final key = event.logicalKey;
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

    if (registry.matches(
      ShortcutCommand.search,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
      return (chatList?.triggerSearch() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (registry.matches(
      ShortcutCommand.escape,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
      if (chat?.handleEscape() == true) return KeyEventResult.handled;
      if (chatList?.handleEscape() == true) return KeyEventResult.handled;
      return KeyEventResult.ignored;
    }

    if (registry.matches(
      ShortcutCommand.openFocusedChat,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
      return (chatList?.openFocused() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (registry.matches(
      ShortcutCommand.replyFocusedMessage,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
      return (chat?.replyFocusedMessage() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (registry.matches(
      ShortcutCommand.editFocusedMessage,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
      return (chat?.editFocusedMessage() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (registry.matches(
      ShortcutCommand.messageFocusUpModified,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
      return (chat?.messageFocusUp() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (registry.matches(
      ShortcutCommand.messageFocusDownModified,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
      return (chat?.messageFocusDown() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (registry.matches(
      ShortcutCommand.chatListFocusUpModified,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
      return (chatList?.focusUp() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (registry.matches(
      ShortcutCommand.chatListFocusDownModified,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
      return (chatList?.focusDown() ?? false)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (registry.matches(
      ShortcutCommand.arrowUp,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
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

    if (registry.matches(
      ShortcutCommand.arrowDown,
      pressedKey: key,
      primaryPressed: primaryPressed,
      altPressed: altPressed,
      shiftPressed: shiftPressed,
    )) {
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
