import 'package:fluffychat/utils/keyboard/keyboard_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KeyboardNavigationState', () {
    test('chat list focus clamps within bounds', () {
      final state = KeyboardNavigationState();

      state.setChatListLength(3);

      state.chatListFocusDown();
      expect(state.focusArea, KeyboardFocusArea.chatList);
      expect(state.chatListFocusIndex, 0);

      state.chatListFocusDown();
      expect(state.chatListFocusIndex, 1);

      state.chatListFocusDown();
      expect(state.chatListFocusIndex, 2);

      state.chatListFocusDown();
      expect(state.chatListFocusIndex, 2);

      state.chatListFocusUp();
      expect(state.chatListFocusIndex, 1);

      state.chatListFocusUp();
      expect(state.chatListFocusIndex, 0);

      state.chatListFocusUp();
      expect(state.chatListFocusIndex, 0);
    });

    test('message focus transitions and reset return to input', () {
      final state = KeyboardNavigationState();

      state.setMessageListLength(3);

      state.messageFocusDown();
      expect(state.focusArea, KeyboardFocusArea.messageList);
      expect(state.messageFocusIndex, 0);
      expect(state.hasMessageFocus, isTrue);

      state.messageFocusDown();
      expect(state.messageFocusIndex, 1);

      state.messageFocusUp();
      expect(state.messageFocusIndex, 0);

      state.messageFocusLast();
      expect(state.messageFocusIndex, 0);

      state.resetMessageFocus();
      expect(state.messageFocusIndex, -1);
      expect(state.focusArea, KeyboardFocusArea.input);
      expect(state.hasMessageFocus, isFalse);
    });

    test('shrinking list lengths clamps focused indices', () {
      final state = KeyboardNavigationState();

      state.setChatListLength(4);
      state.chatListFocusDown();
      state.chatListFocusDown();
      state.chatListFocusDown();
      expect(state.chatListFocusIndex, 2);

      state.setChatListLength(2);
      expect(state.chatListFocusIndex, 1);

      state.setMessageListLength(4);
      state.messageFocusDown();
      state.messageFocusDown();
      state.messageFocusDown();
      expect(state.messageFocusIndex, 2);

      state.setMessageListLength(2);
      expect(state.messageFocusIndex, 1);
    });

    test('clearAllFocus clears both areas and selects input', () {
      final state = KeyboardNavigationState();

      state.setChatListLength(2);
      state.chatListFocusDown();
      state.setMessageListLength(2);
      state.messageFocusDown();

      state.clearAllFocus();

      expect(state.chatListFocusIndex, -1);
      expect(state.messageFocusIndex, -1);
      expect(state.focusArea, KeyboardFocusArea.input);
      expect(state.hasChatListFocus, isFalse);
      expect(state.hasMessageFocus, isFalse);
    });
  });
}
