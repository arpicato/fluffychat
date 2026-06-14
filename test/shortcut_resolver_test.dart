import 'package:fluffychat/utils/keyboard/shortcut_dispatcher.dart';
import 'package:fluffychat/utils/keyboard/shortcut_resolver.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShortcutResolver', () {
    final resolver = ShortcutResolver();

    test('Ctrl+K triggers chat list search', () {
      final chatList = _FakeChatListHandler(triggerSearchResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.keyK,
          primaryPressed: true,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: false,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chatList: chatList,
      );

      expect(handled, isTrue);
      expect(chatList.searchCalls, 1);
    });

    test('Up focuses chat list when no chat is open', () {
      final chatList = _FakeChatListHandler(focusUpResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowUp,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: false,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chatList: chatList,
      );

      expect(handled, isTrue);
      expect(chatList.focusUpCalls, 1);
    });

    test('Up focuses messages from composer first line', () {
      final chat = _FakeChatHandler(
        inputHasFocus: true,
        composerCaretOnTopVisualLine: true,
        composerSuggestionsOpen: false,
        messageFocusUpResult: true,
      );

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowUp,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.messageFocusUpCalls, 1);
    });

    test('Space toggles highlighted message selection', () {
      final chat = _FakeChatHandler(toggleFocusedMessageSelectionResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.space,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: true,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.toggleFocusedMessageSelectionCalls, 1);
    });

    test('Alt+J jumps to recent messages', () {
      final chat = _FakeChatHandler(jumpToRecentResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.keyJ,
          primaryPressed: false,
          altPressed: true,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.jumpToRecentCalls, 1);
    });

    test('Alt+F forwards highlighted message', () {
      final chat = _FakeChatHandler(forwardFocusedMessageResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.keyF,
          primaryPressed: false,
          altPressed: true,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.forwardFocusedMessageCalls, 1);
    });

    test('Alt+R replies to highlighted message', () {
      final chat = _FakeChatHandler(replyFocusedMessageResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.keyR,
          primaryPressed: false,
          altPressed: true,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.replyFocusedMessageCalls, 1);
    });

    test('Alt+E edits highlighted message', () {
      final chat = _FakeChatHandler(editFocusedMessageResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.keyE,
          primaryPressed: false,
          altPressed: true,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.editFocusedMessageCalls, 1);
    });

    test('Down moves through messages when message focus is active', () {
      final chat = _FakeChatHandler(
        messageFocusActive: true,
        messageFocusDownResult: true,
      );

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowDown,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.messageFocusDownCalls, 1);
    });

    test('Escape prefers chat handler before chat list handler', () {
      final chat = _FakeChatHandler(handleEscapeResult: true);
      final chatList = _FakeChatListHandler(handleEscapeResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.escape,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
        chatList: chatList,
      );

      expect(handled, isTrue);
      expect(chat.handleEscapeCalls, 1);
      expect(chatList.handleEscapeCalls, 0);
    });

    test('Escape falls back to chat list when chat does not handle it', () {
      final chat = _FakeChatHandler(handleEscapeResult: false);
      final chatList = _FakeChatListHandler(handleEscapeResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.escape,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
        chatList: chatList,
      );

      expect(handled, isTrue);
      expect(chat.handleEscapeCalls, 1);
      expect(chatList.handleEscapeCalls, 1);
    });

    test('Enter opens focused chat list item when chat list is visible', () {
      final chatList = _FakeChatListHandler(openFocusedResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.enter,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: false,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chatList: chatList,
      );

      expect(handled, isTrue);
      expect(chatList.openFocusedCalls, 1);
    });

    test('Alt+Enter also opens focused chat list item', () {
      final chatList = _FakeChatListHandler(openFocusedResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.enter,
          primaryPressed: false,
          altPressed: true,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: false,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chatList: chatList,
      );

      expect(handled, isTrue);
      expect(chatList.openFocusedCalls, 1);
    });

    test('Page up dispatches to chat handler', () {
      final chat = _FakeChatHandler(messagePageUpResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.pageUp,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.messagePageUpCalls, 1);
    });

    test('Page up does not move focus out when composer has focus', () {
      final chat = _FakeChatHandler(
        inputHasFocus: true,
        messagePageUpResult: true,
      );

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.pageUp,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: true,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isFalse);
      expect(chat.messagePageUpCalls, 0);
    });

    test('Page down dispatches to chat handler', () {
      final chat = _FakeChatHandler(messagePageDownResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.pageDown,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.messagePageDownCalls, 1);
    });

    test('Page down does not move focus out when composer has focus', () {
      final chat = _FakeChatHandler(
        inputHasFocus: true,
        messagePageDownResult: true,
      );

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.pageDown,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: true,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isFalse);
      expect(chat.messagePageDownCalls, 0);
    });

    test('Down does not move messages when message focus is inactive', () {
      final chat = _FakeChatHandler(
        inputHasFocus: true,
        messageFocusActive: false,
        messageFocusDownResult: true,
      );

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowDown,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isFalse);
      expect(chat.messageFocusDownCalls, 0);
    });

    test('Down yields to composer suggestions when autocomplete is open', () {
      final chat = _FakeChatHandler(
        inputHasFocus: true,
        composerSuggestionsOpen: true,
        messageFocusActive: true,
        messageFocusDownResult: true,
      );

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowDown,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isFalse);
      expect(chat.messageFocusDownCalls, 0);
    });

    test('Up does not enter message focus when caret is below top visual line', () {
      final chat = _FakeChatHandler(
        inputHasFocus: true,
        composerCaretOnTopVisualLine: false,
        composerSuggestionsOpen: false,
        messageFocusUpResult: true,
      );

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowUp,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isFalse);
      expect(chat.messageFocusUpCalls, 0);
    });

    test('Up yields to composer suggestions when autocomplete is open', () {
      final chat = _FakeChatHandler(
        inputHasFocus: true,
        composerCaretOnTopVisualLine: true,
        composerSuggestionsOpen: true,
        messageFocusUpResult: true,
      );

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowUp,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isFalse);
      expect(chat.messageFocusUpCalls, 0);
    });

    test('Alt+Up dispatches to chat list modified navigation', () {
      final chatList = _FakeChatListHandler(focusUpResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowUp,
          primaryPressed: false,
          altPressed: true,
          shiftPressed: false,
        ),
        context: const ShortcutContext(
          hasOpenChat: false,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chatList: chatList,
      );

      expect(handled, isTrue);
      expect(chatList.focusUpCalls, 1);
    });

    test('Alt+Shift+Down dispatches to modified message navigation', () {
      final chat = _FakeChatHandler(messageFocusDownResult: true);

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowDown,
          primaryPressed: false,
          altPressed: true,
          shiftPressed: true,
        ),
        context: const ShortcutContext(
          hasOpenChat: true,
          textFieldFocused: false,
          messageFocused: false,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.messageFocusDownCalls, 1);
    });
  });
}

class _FakeChatListHandler implements KeyboardChatListHandler {
  _FakeChatListHandler({
    this.triggerSearchResult = false,
    this.focusUpResult = false,
    this.openFocusedResult = false,
    this.handleEscapeResult = false,
  });

  final bool triggerSearchResult;
  final bool focusUpResult;
  final bool openFocusedResult;
  final bool handleEscapeResult;

  int searchCalls = 0;
  int focusUpCalls = 0;
  int focusDownCalls = 0;
  int openFocusedCalls = 0;
  int handleEscapeCalls = 0;

  @override
  bool focusDown() {
    focusDownCalls++;
    return false;
  }

  @override
  bool focusUp() {
    focusUpCalls++;
    return focusUpResult;
  }

  @override
  bool handleEscape() {
    handleEscapeCalls++;
    return handleEscapeResult;
  }

  @override
  bool openFocused() {
    openFocusedCalls++;
    return openFocusedResult;
  }

  @override
  bool triggerSearch() {
    searchCalls++;
    return triggerSearchResult;
  }
}

class _FakeChatHandler implements KeyboardChatHandler {
  _FakeChatHandler({
    this.inputHasFocus = false,
    this.composerCaretOnTopVisualLine = false,
    this.composerSuggestionsOpen = false,
    this.messageFocusActive = false,
    this.jumpToRecentResult = false,
    this.messagePageUpResult = false,
    this.messagePageDownResult = false,
    this.toggleFocusedMessageSelectionResult = false,
    this.forwardFocusedMessageResult = false,
    this.messageFocusUpResult = false,
    this.messageFocusDownResult = false,
    this.replyFocusedMessageResult = false,
    this.editFocusedMessageResult = false,
    this.handleEscapeResult = false,
  });

  @override
  final bool inputHasFocus;

  @override
  final bool composerCaretOnTopVisualLine;

  @override
  final bool composerSuggestionsOpen;

  @override
  final bool messageFocusActive;

  final bool jumpToRecentResult;
  final bool messagePageUpResult;
  final bool messagePageDownResult;
  final bool toggleFocusedMessageSelectionResult;
  final bool forwardFocusedMessageResult;
  final bool messageFocusUpResult;
  final bool messageFocusDownResult;
  final bool replyFocusedMessageResult;
  final bool editFocusedMessageResult;
  final bool handleEscapeResult;

  int messageFocusUpCalls = 0;
  int messageFocusDownCalls = 0;
  int jumpToRecentCalls = 0;
  int messagePageUpCalls = 0;
  int messagePageDownCalls = 0;
  int toggleFocusedMessageSelectionCalls = 0;
  int forwardFocusedMessageCalls = 0;
  int replyFocusedMessageCalls = 0;
  int editFocusedMessageCalls = 0;
  int exitMessageFocusToInputCalls = 0;
  int handleEscapeCalls = 0;

  @override
  bool editFocusedMessage() {
    editFocusedMessageCalls++;
    return editFocusedMessageResult;
  }

  @override
  bool exitMessageFocusToInput() {
    exitMessageFocusToInputCalls++;
    return false;
  }

  @override
  bool handleEscape() {
    handleEscapeCalls++;
    return handleEscapeResult;
  }

  @override
  bool jumpToRecent() {
    jumpToRecentCalls++;
    return jumpToRecentResult;
  }

  @override
  bool messageFocusDown() {
    messageFocusDownCalls++;
    return messageFocusDownResult;
  }

  @override
  bool messageFocusUp() {
    messageFocusUpCalls++;
    return messageFocusUpResult;
  }

  @override
  bool messagePageDown() {
    messagePageDownCalls++;
    return messagePageDownResult;
  }

  @override
  bool messagePageUp() {
    messagePageUpCalls++;
    return messagePageUpResult;
  }

  @override
  bool toggleFocusedMessageSelection() {
    toggleFocusedMessageSelectionCalls++;
    return toggleFocusedMessageSelectionResult;
  }

  @override
  bool forwardFocusedMessage() {
    forwardFocusedMessageCalls++;
    return forwardFocusedMessageResult;
  }

  @override
  bool replyFocusedMessage() {
    replyFocusedMessageCalls++;
    return replyFocusedMessageResult;
  }
}
