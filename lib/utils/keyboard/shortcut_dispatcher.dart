import 'package:flutter/widgets.dart';

abstract class KeyboardChatListHandler {
  bool triggerSearch();
  bool focusUp();
  bool focusDown();
  bool openFocused();
  bool handleEscape();
}

abstract class KeyboardChatHandler {
  bool get inputHasFocus;
  bool get composerCursorOnFirstLine;
  bool get messageFocusActive;
  bool messageFocusUp();
  bool messageFocusDown();
  bool toggleFocusedMessageSelection();
  bool replyFocusedMessage();
  bool editFocusedMessage();
  bool exitMessageFocusToInput();
  bool handleEscape();
}

class ShortcutDispatcher {
  ShortcutDispatcher._();

  static final ShortcutDispatcher instance = ShortcutDispatcher._();

  KeyboardChatListHandler? chatListHandler;
  KeyboardChatHandler? chatHandler;

  void registerChatListHandler(KeyboardChatListHandler handler) {
    chatListHandler = handler;
  }

  void unregisterChatListHandler(KeyboardChatListHandler handler) {
    if (identical(chatListHandler, handler)) chatListHandler = null;
  }

  void registerChatHandler(KeyboardChatHandler handler) {
    chatHandler = handler;
  }

  void unregisterChatHandler(KeyboardChatHandler handler) {
    if (identical(chatHandler, handler)) chatHandler = null;
  }
}
