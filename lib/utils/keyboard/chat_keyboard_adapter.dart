import 'package:collection/collection.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/filtered_timeline_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'keyboard_navigation.dart';
import 'shortcut_dispatcher.dart';

class ChatKeyboardHandlerAdapter implements KeyboardChatHandler {
  ChatKeyboardHandlerAdapter(this.controller);

  final ChatController controller;

  @override
  bool get inputHasFocus => controller.inputFocus.hasFocus;

  @override
  bool get composerCursorOnFirstLine {
    final selection = controller.sendController.selection;
    if (!selection.isValid) return true;
    final offset = selection.baseOffset.clamp(
      0,
      controller.sendController.text.length,
    );
    final prefix = controller.sendController.text.substring(0, offset);
    return !prefix.contains('\n');
  }

  @override
  bool get messageFocusActive =>
      KeyboardNavigation.maybeOf(controller.context)?.focusArea ==
      KeyboardFocusArea.messageList;

  List<Event> get _visibleKeyboardEvents =>
      controller.timeline
          ?.events
          .filterByVisibleInGui(threadId: controller.activeThreadId)
          .toList() ??
      const [];

  @override
  bool messageFocusUp() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav == null) return false;
    final events = _visibleKeyboardEvents;
    if (events.isEmpty) return false;
    keyboardNav.setMessageListLength(events.length);
    keyboardNav.messageFocusDown();
    return true;
  }

  @override
  bool messageFocusDown() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav == null) return false;
    final events = _visibleKeyboardEvents;
    if (events.isEmpty) return false;
    keyboardNav.setMessageListLength(events.length);
    if (keyboardNav.focusArea == KeyboardFocusArea.messageList &&
        keyboardNav.messageFocusIndex <= 0) {
      keyboardNav.resetMessageFocus();
      controller.inputFocus.requestFocus();
      return true;
    }
    keyboardNav.messageFocusUp();
    return true;
  }

  @override
  bool replyFocusedMessage() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav == null) return false;
    final events = _visibleKeyboardEvents;
    if (events.isEmpty) return false;
    if (keyboardNav.focusArea != KeyboardFocusArea.messageList) return false;
    final idx = keyboardNav.messageFocusIndex;
    final target = idx >= 0 && idx < events.length ? events[idx] : events.first;
    controller.replyAction(replyTo: target);
    keyboardNav.resetMessageFocus();
    return true;
  }

  @override
  bool editFocusedMessage() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav == null) return false;
    final events = _visibleKeyboardEvents;
    if (events.isEmpty) return false;
    if (keyboardNav.focusArea != KeyboardFocusArea.messageList) return false;
    final ownUserId = controller.room.client.userID;
    final idx = keyboardNav.messageFocusIndex;
    final target = idx >= 0 && idx < events.length
        ? events[idx]
        : events.firstWhereOrNull((e) => e.senderId == ownUserId);
    if (target == null || target.senderId != ownUserId) return false;
    controller.selectedEvents
      ..clear()
      ..add(target);
    controller.editSelectedEventAction();
    keyboardNav.resetMessageFocus();
    return true;
  }

  @override
  bool exitMessageFocusToInput() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav?.focusArea != KeyboardFocusArea.messageList) return false;
    keyboardNav!.resetMessageFocus();
    controller.inputFocus.requestFocus();
    return true;
  }

  @override
  bool handleEscape() {
    final keyboardNav = KeyboardNavigation.maybeOf(controller.context);
    if (keyboardNav?.focusArea == KeyboardFocusArea.messageList) {
      keyboardNav!.resetMessageFocus();
      controller.inputFocus.requestFocus();
      return true;
    }
    if (controller.replyEvent != null || controller.editEvent != null) {
      controller.cancelReplyEventAction();
      controller.inputFocus.requestFocus();
      return true;
    }
    if (controller.selectedEvents.isNotEmpty) {
      controller.clearSelectedEvents();
      return true;
    }
    if (controller.activeThreadId != null) {
      controller.closeThread();
      return true;
    }
    if (controller.mounted && controller.context.canPop()) {
      controller.context.pop();
      return true;
    }
    return false;
  }
}
