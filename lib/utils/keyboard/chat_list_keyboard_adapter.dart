import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_list/chat_list_entries.dart';
import 'package:go_router/go_router.dart';

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
    final entries = controller.navigableEntries;
    final idx = keyboardNav.chatListFocusIndex;
    if (idx < 0 || idx >= entries.length) return false;
    final entry = entries[idx];
    switch (entry) {
      case RoomChatListEntry(:final room):
        controller.onChatTap(room);
        return true;
      case TodoChatListEntry(:final todoList):
        controller.context.push(
          '/rooms/todos/${todoList.id}',
          extra: <String, Object?>{
            'title': todoList.title,
            'description': todoList.description,
          },
        );
        return true;
      case CalendarChatListEntry(:final event):
        controller.context.push(
          '/rooms/calendar/events/${event.id}',
          extra: <String, Object?>{
            'title': event.title,
            'sourceDisplayName': event.sourceDisplayName,
          },
        );
        return true;
      case DividerChatListEntry():
        return false;
    }
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
    // If we can pop (e.g. todo/calendar detail page is open), close it.
    if (controller.mounted && controller.context.canPop()) {
      controller.context.pop();
      return true;
    }
    return false;
  }
}
