import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Tracks which area of the UI currently has keyboard focus.
/// This determines how shortcuts are dispatched.
enum KeyboardFocusArea {
  /// Chat list panel — arrow keys navigate rooms
  chatList,

  /// Message timeline — arrow keys navigate messages
  messageList,

  /// Text input field — normal typing, shortcuts mostly disabled
  input,
}

/// Provides keyboard navigation state to the widget tree.
/// Sits above the router so all pages can read/write focus state.
class KeyboardNavigationState extends ChangeNotifier {
  KeyboardFocusArea _focusArea = KeyboardFocusArea.chatList;
  int _chatListFocusIndex = -1;
  int _messageFocusIndex = -1;
  int _chatListLength = 0;
  int _messageListLength = 0;

  KeyboardFocusArea get focusArea => _focusArea;
  int get chatListFocusIndex => _chatListFocusIndex;
  int get messageFocusIndex => _messageFocusIndex;

  /// Whether the chat list has a focused (highlighted) item.
  bool get hasChatListFocus =>
      _focusArea == KeyboardFocusArea.chatList && _chatListFocusIndex >= 0;

  /// Whether the message list has a focused (highlighted) item.
  bool get hasMessageFocus =>
      _focusArea == KeyboardFocusArea.messageList && _messageFocusIndex >= 0;

  void setFocusArea(KeyboardFocusArea area) {
    if (_focusArea == area) return;
    _focusArea = area;
    notifyListeners();
  }

  void setChatListLength(int length) {
    _chatListLength = length;
    if (_chatListFocusIndex >= length) {
      _chatListFocusIndex = length - 1;
      notifyListeners();
    }
  }

  void setMessageListLength(int length) {
    _messageListLength = length;
    if (_messageFocusIndex >= length) {
      _messageFocusIndex = length - 1;
      notifyListeners();
    }
  }

  // -- Chat list navigation --

  void chatListFocusUp() {
    if (_chatListLength == 0) return;
    _focusArea = KeyboardFocusArea.chatList;
    if (_chatListFocusIndex <= 0) {
      _chatListFocusIndex = 0;
    } else {
      _chatListFocusIndex--;
    }
    notifyListeners();
  }

  void chatListFocusDown() {
    if (_chatListLength == 0) return;
    _focusArea = KeyboardFocusArea.chatList;
    if (_chatListFocusIndex < _chatListLength - 1) {
      _chatListFocusIndex++;
    }
    notifyListeners();
  }

  void resetChatListFocus() {
    _chatListFocusIndex = -1;
    notifyListeners();
  }

  // -- Message list navigation --

  void messageFocusUp() {
    if (_messageListLength == 0) return;
    _focusArea = KeyboardFocusArea.messageList;
    if (_messageFocusIndex <= 0) {
      _messageFocusIndex = 0;
    } else {
      _messageFocusIndex--;
    }
    notifyListeners();
  }

  void messageFocusDown() {
    if (_messageListLength == 0) return;
    _focusArea = KeyboardFocusArea.messageList;
    if (_messageFocusIndex < 0) {
      _messageFocusIndex = 0;
    } else if (_messageFocusIndex < _messageListLength - 1) {
      _messageFocusIndex++;
    }
    notifyListeners();
  }

  /// Focus the last message (for reply default) or last own message (for edit).
  void messageFocusLast() {
    if (_messageListLength == 0) return;
    _focusArea = KeyboardFocusArea.messageList;
    _messageFocusIndex = 0; // index 0 = most recent in reversed list
    notifyListeners();
  }

  void resetMessageFocus() {
    _messageFocusIndex = -1;
    if (_focusArea == KeyboardFocusArea.messageList) {
      _focusArea = KeyboardFocusArea.input;
    }
    notifyListeners();
  }

  void clearAllFocus() {
    _chatListFocusIndex = -1;
    _messageFocusIndex = -1;
    _focusArea = KeyboardFocusArea.input;
    notifyListeners();
  }
}

/// InheritedWidget to provide KeyboardNavigationState down the tree.
class KeyboardNavigation extends InheritedNotifier<KeyboardNavigationState> {
  const KeyboardNavigation({
    super.key,
    required KeyboardNavigationState state,
    required super.child,
  }) : super(notifier: state);

  static KeyboardNavigationState of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<KeyboardNavigation>();
    assert(widget != null, 'No KeyboardNavigation found in context');
    return widget!.notifier!;
  }

  static KeyboardNavigationState? maybeOf(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<KeyboardNavigation>();
    return widget?.notifier;
  }
}
