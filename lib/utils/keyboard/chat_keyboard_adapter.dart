import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/filtered_timeline_extension.dart';
import 'package:fluffychat/utils/show_scaffold_dialog.dart';
import 'package:fluffychat/widgets/share_scaffold_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

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
  bool get messageFocusActive {
    // Message focus is active if the primary focus is NOT the composer
    // and not null.
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;
    if (primaryFocus == controller.inputFocus) return false;
    // Only count as active if focus is actually inside the chat page
    // (not in a dialog or other overlay).
    return !controller.inputFocus.hasFocus;
  }

  @override
  bool messageFocusUp() {
    final scope = controller.messageFocusScope;
    if (scope == null) return false;
    // If no message is currently focused (e.g. after Esc or first entry),
    // focus the last traversable node (most recent message has highest order
    // in our reversed list).
    if (controller.focusedMessageIndex < 0) {
      final context = scope.context;
      if (context != null) {
        final policy = FocusTraversalGroup.of(context);
        final last = policy.findLastFocus(scope, ignoreCurrentFocus: true);
        if (last != null) {
          last.requestFocus();
          return true;
        }
      }
      scope.previousFocus();
      return true;
    }
    scope.previousFocus();
    return true;
  }

  @override
  bool messageFocusDown() {
    final scope = controller.messageFocusScope;
    if (scope == null) return false;
    // If at the bottom-most message (index 0 in reversed list), return to composer.
    if (controller.focusedMessageIndex == 0) {
      controller.focusedEvent = null;
      controller.focusedMessageIndex = -1;
      controller.inputFocus.requestFocus();
      return true;
    }
    scope.nextFocus();
    return true;
  }

  @override
  bool messagePageUp() {
    final scope = controller.messageFocusScope;
    if (scope == null) return false;
    for (var i = 0; i < 10; i++) {
      scope.previousFocus();
    }
    return true;
  }

  @override
  bool messagePageDown() {
    final scope = controller.messageFocusScope;
    if (scope == null) return false;
    for (var i = 0; i < 10; i++) {
      scope.nextFocus();
    }
    return true;
  }

  List<Event> get _visibleEvents =>
      controller.timeline
          ?.events
          .filterByVisibleInGui(threadId: controller.activeThreadId)
          .toList() ??
      const [];

  /// Returns the target event for actions: focused message first,
  /// then single selected message, then intelligently picks the last
  /// relevant message in the chat.
  Event? _actionTarget({bool ownMessageOnly = false}) {
    final ownUserId = controller.room.client.userID;
    Event? candidate = controller.focusedEvent;
    if (candidate == null && controller.selectedEvents.length == 1) {
      candidate = controller.selectedEvents.single;
    }
    // Fallback: pick the last relevant message in the visible timeline.
    if (candidate == null) {
      final events = _visibleEvents;
      if (ownMessageOnly) {
        candidate = events.cast<Event?>().firstWhere(
          (e) => e!.senderId == ownUserId,
          orElse: () => null,
        );
      } else {
        candidate = events.isNotEmpty ? events.first : null;
      }
    }
    if (candidate == null) return null;
    if (ownMessageOnly && candidate.senderId != ownUserId) return null;
    return candidate;
  }

  @override
  bool toggleFocusedMessageSelection() {
    final target = controller.focusedEvent;
    if (target == null) return false;
    controller.onSelectMessage(target);
    return true;
  }

  @override
  bool forwardFocusedMessage() {
    final target = _actionTarget();
    if (target == null) return false;
    final timeline = controller.timeline;
    if (timeline == null) return false;
    final displayEvent = target.getDisplayEvent(timeline);
    _showForwardDialog(displayEvent);
    return true;
  }

  Future<void> _showForwardDialog(Event displayEvent) async {
    await showScaffoldDialog(
      context: controller.context,
      builder: (context) => ShareScaffoldDialog(
        items: [ContentShareItem(displayEvent.content)],
      ),
    );
  }

  @override
  bool replyFocusedMessage() {
    final target = _actionTarget();
    if (target == null) return false;
    controller.replyAction(replyTo: target);
    return true;
  }

  @override
  bool editFocusedMessage() {
    final target = _actionTarget(ownMessageOnly: true);
    if (target == null) return false;
    controller.selectedEvents
      ..clear()
      ..add(target);
    controller.editSelectedEventAction();
    return true;
  }

  @override
  bool exitMessageFocusToInput() {
    controller.inputFocus.requestFocus();
    return true;
  }

  @override
  bool handleEscape() {
    if (controller.replyEvent != null || controller.editEvent != null) {
      controller.cancelReplyEventAction();
      controller.inputFocus.requestFocus();
      return true;
    }
    if (controller.selectedEvents.isNotEmpty) {
      controller.clearSelectedEvents();
      return true;
    }
    // If focus is not on composer, return it there and clear focused event.
    if (!controller.inputFocus.hasFocus) {
      controller.focusedEvent = null;
      controller.focusedMessageIndex = -1;
      controller.inputFocus.requestFocus();
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
