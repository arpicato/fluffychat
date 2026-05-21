import 'package:collection/collection.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/utils/keyboard/intents.dart';
import 'package:fluffychat/utils/keyboard/keyboard_navigation.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/filtered_timeline_extension.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

/// Keyboard Actions wrapper for the chat message area.
/// Handles Up/Down navigation, R for reply, E for edit.
class ChatKeyboardActions extends StatelessWidget {
  static final FocusNode _keyboardFocusNode = FocusNode(
    debugLabel: 'ChatKeyboardScope',
  );

  const ChatKeyboardActions({
    super.key,
    required this.controller,
    required this.child,
  });

  final ChatController controller;
  final Widget child;

  List<Event> get _visibleEvents {
    final timeline = controller.timeline;
    if (timeline == null) return [];
    return timeline.events.filterByVisibleInGui(
      threadId: controller.activeThreadId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardNav = KeyboardNavigation.maybeOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FocusManager.instance.primaryFocus != null) return;
      if (_keyboardFocusNode.hasFocus) return;
      debugPrint('[kb/focus] requesting ChatKeyboardScope');
      _keyboardFocusNode.requestFocus();
    });

    return Actions(
      actions: <Type, Action<Intent>>{
        MessageFocusUpIntent: CallbackAction<MessageFocusUpIntent>(
          onInvoke: (_) {
            debugPrint('[kb/action] MessageFocusUpIntent');
            if (keyboardNav == null) return null;
            final events = _visibleEvents;
            if (events.isEmpty) return null;
            keyboardNav.setMessageListLength(events.length);
            keyboardNav.messageFocusUp();
            return null;
          },
        ),
        MessageFocusDownIntent: CallbackAction<MessageFocusDownIntent>(
          onInvoke: (_) {
            debugPrint('[kb/action] MessageFocusDownIntent');
            if (keyboardNav == null) return null;
            final events = _visibleEvents;
            if (events.isEmpty) return null;
            keyboardNav.setMessageListLength(events.length);
            keyboardNav.messageFocusDown();
            return null;
          },
        ),
        MessageReplyIntent: CallbackAction<MessageReplyIntent>(
          onInvoke: (_) {
            debugPrint('[kb/action] MessageReplyIntent');
            if (keyboardNav == null) return null;
            if (keyboardNav.focusArea != KeyboardFocusArea.messageList) {
              return null;
            }
            final events = _visibleEvents;
            final idx = keyboardNav.messageFocusIndex;
            if (idx >= 0 && idx < events.length) {
              controller.replyAction(replyTo: events[idx]);
            } else if (events.isNotEmpty) {
              controller.replyAction(replyTo: events.first);
            }
            keyboardNav.resetMessageFocus();
            return null;
          },
        ),
        MessageEditIntent: CallbackAction<MessageEditIntent>(
          onInvoke: (_) {
            debugPrint('[kb/action] MessageEditIntent');
            if (keyboardNav == null) return null;
            if (keyboardNav.focusArea != KeyboardFocusArea.messageList) {
              return null;
            }
            final events = _visibleEvents;
            final ownUserId = controller.room.client.userID;
            final idx = keyboardNav.messageFocusIndex;

            Event? targetEvent;
            if (idx >= 0 && idx < events.length) {
              targetEvent = events[idx];
            } else {
              // Default: last own message
              targetEvent =
                  events.firstWhereOrNull((e) => e.senderId == ownUserId);
            }
            if (targetEvent == null || targetEvent.senderId != ownUserId) {
              return null;
            }
            controller.selectedEvents
              ..clear()
              ..add(targetEvent);
            controller.editSelectedEventAction();
            keyboardNav.resetMessageFocus();
            return null;
          },
        ),
      },
      child: Focus(
        autofocus: true,
        focusNode: _keyboardFocusNode,
        onFocusChange: (focused) => debugPrint(
          '[kb/focus] ChatKeyboardScope focused=$focused',
        ),
        child: child,
      ),
    );
  }
}
