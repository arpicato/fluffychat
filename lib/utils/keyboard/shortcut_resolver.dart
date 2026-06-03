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

/// Runtime context evaluated once per key event.
/// The resolver checks each command's `when` conditions against this.
class ShortcutContext {
  const ShortcutContext({
    required this.hasOpenChat,
    required this.textFieldFocused,
    required this.messageFocused,
    required this.modalOpen,
  });

  /// A chat room page is the current route.
  final bool hasOpenChat;

  /// Any text input field currently has focus (composer, search, todo title, etc).
  final bool textFieldFocused;

  /// A message in the timeline has native focus (via our focus traversal).
  final bool messageFocused;

  /// A modal/dialog route is on top (image viewer, share dialog, etc).
  final bool modalOpen;
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
    // Skip all shortcuts when a modal is open (let the modal handle keys).
    if (context.modalOpen &&
        keyState.key == LogicalKeyboardKey.escape) {
      return false;
    }

    // Try each command definition in priority order.
    for (final definition in registry.definitions) {
      // Check if the key matches this command's bindings.
      final matches = definition.bindings.any(
        (binding) => binding.matches(
          pressedKey: keyState.key,
          primaryPressed: keyState.primaryPressed,
          altPressed: keyState.altPressed,
          shiftPressed: keyState.shiftPressed,
        ),
      );
      if (!matches) continue;

      // Check if all conditions are satisfied.
      if (!_conditionsMet(definition, context)) continue;

      // Dispatch to the appropriate handler.
      final handled = _dispatch(definition.command, context, chat, chatList);
      if (handled) return true;
    }

    return false;
  }

  bool _conditionsMet(ShortcutDefinition definition, ShortcutContext context) {
    for (final condition in definition.when) {
      switch (condition) {
        case ShortcutWhen.chatVisible:
          if (!context.hasOpenChat) return false;
        case ShortcutWhen.chatListVisible:
          if (context.hasOpenChat) return false;
        case ShortcutWhen.messageFocused:
          if (!context.messageFocused) return false;
        case ShortcutWhen.textFieldNotFocused:
          if (context.textFieldFocused) return false;
        case ShortcutWhen.noModalOpen:
          if (context.modalOpen) return false;
      }
    }
    return true;
  }

  bool _dispatch(
    ShortcutCommand command,
    ShortcutContext context,
    KeyboardChatHandler? chat,
    KeyboardChatListHandler? chatList,
  ) {
    switch (command) {
      case ShortcutCommand.search:
        return chatList?.triggerSearch() ?? false;

      case ShortcutCommand.escape:
        if (chat?.handleEscape() == true) return true;
        if (chatList?.handleEscape() == true) return true;
        return false;

      case ShortcutCommand.openFocusedChat:
        return chatList?.openFocused() ?? false;

      case ShortcutCommand.toggleFocusedMessageSelection:
        return chat?.toggleFocusedMessageSelection() ?? false;

      case ShortcutCommand.forwardFocusedMessage:
        return chat?.forwardFocusedMessage() ?? false;

      case ShortcutCommand.replyFocusedMessage:
        return chat?.replyFocusedMessage() ?? false;

      case ShortcutCommand.editFocusedMessage:
        return chat?.editFocusedMessage() ?? false;

      case ShortcutCommand.messageFocusUpModified:
        return chat?.messageFocusUp() ?? false;

      case ShortcutCommand.messageFocusDownModified:
        return chat?.messageFocusDown() ?? false;

      case ShortcutCommand.messagePageUp:
        if (chat?.inputHasFocus == true) return false;
        return chat?.messagePageUp() ?? false;

      case ShortcutCommand.messagePageDown:
        if (chat?.inputHasFocus == true) return false;
        return chat?.messagePageDown() ?? false;

      case ShortcutCommand.chatListFocusUpModified:
        return chatList?.focusUp() ?? false;

      case ShortcutCommand.chatListFocusDownModified:
        return chatList?.focusDown() ?? false;

      case ShortcutCommand.arrowUp:
        if (!context.hasOpenChat) {
          return chatList?.focusUp() ?? false;
        }
        if (chat?.composerSuggestionsOpen == true) {
          return false;
        }
        if (chat != null &&
            (!chat.inputHasFocus || chat.composerCaretOnTopVisualLine)) {
          return chat.messageFocusUp();
        }
        return false;

      case ShortcutCommand.arrowDown:
        if (!context.hasOpenChat) {
          return chatList?.focusDown() ?? false;
        }
        if (chat?.composerSuggestionsOpen == true) {
          return false;
        }
        if (chat?.messageFocusActive == true) {
          return chat?.messageFocusDown() ?? false;
        }
        return false;
    }
  }
}
