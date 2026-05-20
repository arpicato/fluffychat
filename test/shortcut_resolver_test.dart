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
        context: const ShortcutContext(hasOpenChat: false),
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
        context: const ShortcutContext(hasOpenChat: false),
        chatList: chatList,
      );

      expect(handled, isTrue);
      expect(chatList.focusUpCalls, 1);
    });

    test('Up focuses messages from composer first line', () {
      final chat = _FakeChatHandler(
        inputHasFocus: true,
        composerCursorOnFirstLine: true,
        messageFocusUpResult: true,
      );

      final handled = resolver.resolve(
        keyState: const ShortcutKeyState(
          key: LogicalKeyboardKey.arrowUp,
          primaryPressed: false,
          altPressed: false,
          shiftPressed: false,
        ),
        context: const ShortcutContext(hasOpenChat: true),
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
        context: const ShortcutContext(hasOpenChat: true),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.toggleFocusedMessageSelectionCalls, 1);
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
        context: const ShortcutContext(hasOpenChat: true),
        chat: chat,
      );

      expect(handled, isTrue);
      expect(chat.forwardFocusedMessageCalls, 1);
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
        context: const ShortcutContext(hasOpenChat: true),
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
        context: const ShortcutContext(hasOpenChat: true),
        chat: chat,
        chatList: chatList,
      );

      expect(handled, isTrue);
      expect(chat.handleEscapeCalls, 1);
      expect(chatList.handleEscapeCalls, 0);
    });
  });
}

class _FakeChatListHandler implements KeyboardChatListHandler {
  _FakeChatListHandler({
    this.triggerSearchResult = false,
    this.focusUpResult = false,
    this.focusDownResult = false,
    this.openFocusedResult = false,
    this.handleEscapeResult = false,
  });

  final bool triggerSearchResult;
  final bool focusUpResult;
  final bool focusDownResult;
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
    return focusDownResult;
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
    this.composerCursorOnFirstLine = false,
    this.messageFocusActive = false,
    this.toggleFocusedMessageSelectionResult = false,
    this.forwardFocusedMessageResult = false,
    this.messageFocusUpResult = false,
    this.messageFocusDownResult = false,
    this.replyFocusedMessageResult = false,
    this.editFocusedMessageResult = false,
    this.exitMessageFocusToInputResult = false,
    this.handleEscapeResult = false,
  });

  @override
  final bool inputHasFocus;

  @override
  final bool composerCursorOnFirstLine;

  @override
  final bool messageFocusActive;

  final bool toggleFocusedMessageSelectionResult;
  final bool forwardFocusedMessageResult;
  final bool messageFocusUpResult;
  final bool messageFocusDownResult;
  final bool replyFocusedMessageResult;
  final bool editFocusedMessageResult;
  final bool exitMessageFocusToInputResult;
  final bool handleEscapeResult;

  int messageFocusUpCalls = 0;
  int messageFocusDownCalls = 0;
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
    return exitMessageFocusToInputResult;
  }

  @override
  bool handleEscape() {
    handleEscapeCalls++;
    return handleEscapeResult;
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
