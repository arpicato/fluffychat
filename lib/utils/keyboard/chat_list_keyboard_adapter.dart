import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_list/chat_list_entries.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final entries = controller.navigableEntries;
    if (entries.isEmpty) return false;
    final currentIdx = controller.focusedChatListIndex;
    final newIdx = currentIdx <= 0 ? 0 : currentIdx - 1;
    final node = controller.chatListFocusNodes[newIdx];
    if (node != null) {
      node.requestFocus();
    }
    return true;
  }

  @override
  bool focusDown() {
    final entries = controller.navigableEntries;
    if (entries.isEmpty) return false;
    final currentIdx = controller.focusedChatListIndex;
    final newIdx = currentIdx < 0 ? 0 : (currentIdx + 1).clamp(0, entries.length - 1);
    final node = controller.chatListFocusNodes[newIdx];
    if (node != null) {
      node.requestFocus();
    }
    return true;
  }

  @override
  bool openFocused() {
    final entry = controller.focusedChatListEntry;
    if (entry == null) return false;
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
  bool openByIndex(int index) {
    // Only count non-calendar entries
    final entries = controller.navigableEntries
        .where((e) => e is! CalendarChatListEntry)
        .toList();
    if (index < 0 || index >= entries.length) return false;
    final entry = entries[index];
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
      case CalendarChatListEntry():
        return false;
      case DividerChatListEntry():
        return false;
    }
  }

  @override
  bool handleEscape() {
    // If we can pop (e.g. todo/calendar detail page is open), close it first.
    if (controller.mounted && controller.context.canPop()) {
      controller.context.pop();
      return true;
    }
    // If a chat list item is focused, unfocus it.
    if (controller.focusedChatListEntry != null) {
      controller.focusedChatListEntry = null;
      controller.focusedChatListIndex = -1;
      FocusManager.instance.primaryFocus?.unfocus();
      return true;
    }
    if (controller.isSearchMode) {
      controller.cancelSearch();
      return true;
    }
    return false;
  }
}
