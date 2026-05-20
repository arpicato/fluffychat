import 'package:fluffychat/pages/chat_list/chat_list.dart';

import 'keyboard_navigation.dart';
import 'shortcut_dispatcher.dart';

class ChatListKeyboardHandlerAdapter implements KeyboardChatListHandler {
  ChatListKeyboardHandlerAdapter(this.controller);

  final ChatListController controller;

  @override
  bool triggerSearch() {
    if (!controller.mounted) return false;
    controller.startSearch();
    return true;
  }

  @override
  bool focusUp() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav == null) return false;
    keyboardNav.chatListFocusUp();
    return true;
  }

  @override
  bool focusDown() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav == null) return false;
    keyboardNav.chatListFocusDown();
    return true;
  }

  @override
  bool openFocused() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav == null || !keyboardNav.hasChatListFocus) return false;
    final rooms = controller.filteredRooms;
    final idx = keyboardNav.chatListFocusIndex;
    if (idx < 0 || idx >= rooms.length) return false;
    controller.onChatTap(rooms[idx]);
    return true;
  }

  @override
  bool handleEscape() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav?.hasChatListFocus == true) {
      keyboardNav!.resetChatListFocus();
      return true;
    }
    if (controller.isSearchMode) {
      controller.cancelSearch();
      return true;
    }
    return false;
  }
}
