import 'package:flutter/services.dart';

import 'shortcut_dispatcher.dart';
import 'shortcut_registry.dart';

class ShortcutKeyState {
  const ShortcutKeyState({
    required this.key,
    required this.primaryPressed,
    required this.altPressed,
    required this.shiftPressed,
  });

  final LogicalKeyboardKey key;
  final bool primaryPressed;
  final bool altPressed;
  final bool shiftPressed;
}

class ShortcutContext {
  const ShortcutContext({required this.hasOpenChat});

  final bool hasOpenChat;
}

class ShortcutResolver {
  ShortcutResolver({AppShortcutRegistry? registry})
    : registry = registry ?? AppShortcutRegistry.instance;

  final AppShortcutRegistry registry;

  bool resolve({
    required ShortcutKeyState keyState,
    required ShortcutContext context,
    KeyboardChatHandler? chat,
    KeyboardChatListHandler? chatList,
  }) {
    if (_matches(ShortcutCommand.search, keyState)) {
      return chatList?.triggerSearch() ?? false;
    }

    if (_matches(ShortcutCommand.escape, keyState)) {
      if (chat?.handleEscape() == true) return true;
      if (chatList?.handleEscape() == true) return true;
      return false;
    }

    if (_matches(ShortcutCommand.openFocusedChat, keyState)) {
      return chatList?.openFocused() ?? false;
    }

    if (_matches(ShortcutCommand.toggleFocusedMessageSelection, keyState)) {
      return chat?.toggleFocusedMessageSelection() ?? false;
    }

    if (_matches(ShortcutCommand.forwardFocusedMessage, keyState)) {
      return chat?.forwardFocusedMessage() ?? false;
    }

    if (_matches(ShortcutCommand.replyFocusedMessage, keyState)) {
      return chat?.replyFocusedMessage() ?? false;
    }

    if (_matches(ShortcutCommand.editFocusedMessage, keyState)) {
      return chat?.editFocusedMessage() ?? false;
    }

    if (_matches(ShortcutCommand.messageFocusUpModified, keyState)) {
      return chat?.messageFocusUp() ?? false;
    }

    if (_matches(ShortcutCommand.messageFocusDownModified, keyState)) {
      return chat?.messageFocusDown() ?? false;
    }

    if (_matches(ShortcutCommand.chatListFocusUpModified, keyState)) {
      return chatList?.focusUp() ?? false;
    }

    if (_matches(ShortcutCommand.chatListFocusDownModified, keyState)) {
      return chatList?.focusDown() ?? false;
    }

    if (_matches(ShortcutCommand.arrowUp, keyState)) {
      if (!context.hasOpenChat) {
        return chatList?.focusUp() ?? false;
      }
      if (chat != null && (!chat.inputHasFocus || chat.composerCursorOnFirstLine)) {
        return chat.messageFocusUp();
      }
      return false;
    }

    if (_matches(ShortcutCommand.arrowDown, keyState)) {
      if (!context.hasOpenChat) {
        return chatList?.focusDown() ?? false;
      }
      if (chat?.messageFocusActive == true) {
        return chat?.messageFocusDown() ?? false;
      }
      return false;
    }

    return false;
  }

  bool _matches(ShortcutCommand command, ShortcutKeyState keyState) {
    return registry.matches(
      command,
      pressedKey: keyState.key,
      primaryPressed: keyState.primaryPressed,
      altPressed: keyState.altPressed,
      shiftPressed: keyState.shiftPressed,
    );
  }
}
