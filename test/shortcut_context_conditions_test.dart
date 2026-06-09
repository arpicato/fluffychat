import 'package:fluffychat/utils/keyboard/shortcut_dispatcher.dart';
import 'package:fluffychat/utils/keyboard/shortcut_resolver.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShortcutResolver conditions', () {
    final resolver = ShortcutResolver();

    test('Space is ignored when a text field is focused', () {
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
          textFieldFocused: true,
          messageFocused: true,
          modalOpen: false,
        ),
        chat: chat,
      );

      expect(handled, isFalse);
      expect(chat.toggleFocusedMessageSelectionCalls, 0);
    });

    test('Space works when a message is focused and no text field is focused', () {
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

    test('Reply shortcut is ignored when a modal is open', () {
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
          messageFocused: true,
          modalOpen: true,
        ),
        chat: chat,
      );

      expect(handled, isFalse);
      expect(chat.replyFocusedMessageCalls, 0);
    });

    test('Open focused chat is ignored when a text field is focused', () {
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
          textFieldFocused: true,
          messageFocused: false,
          modalOpen: false,
        ),
        chatList: chatList,
      );

      expect(handled, isFalse);
      expect(chatList.openFocusedCalls, 0);
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
    this.composerSuggestionsOpen = false,
    this.composerCaretOnTopVisualLine = false,
    this.messageFocusActive = false,
    this.messageFocusUpResult = false,
    this.messageFocusDownResult = false,
    this.messagePageUpResult = false,
    this.messagePageDownResult = false,
    this.toggleFocusedMessageSelectionResult = false,
    this.forwardFocusedMessageResult = false,
    this.replyFocusedMessageResult = false,
    this.editFocusedMessageResult = false,
    this.exitMessageFocusToInputResult = false,
    this.handleEscapeResult = false,
  });

  @override
  final bool inputHasFocus;

  @override
  final bool composerSuggestionsOpen;

  @override
  final bool composerCaretOnTopVisualLine;

  @override
  final bool messageFocusActive;

  final bool messageFocusUpResult;
  final bool messageFocusDownResult;
  final bool messagePageUpResult;
  final bool messagePageDownResult;
  final bool toggleFocusedMessageSelectionResult;
  final bool forwardFocusedMessageResult;
  final bool replyFocusedMessageResult;
  final bool editFocusedMessageResult;
  final bool exitMessageFocusToInputResult;
  final bool handleEscapeResult;

  int messageFocusUpCalls = 0;
  int messageFocusDownCalls = 0;
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
