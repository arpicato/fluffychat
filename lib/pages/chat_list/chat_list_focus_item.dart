// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import 'chat_list.dart';

/// Focus wrapper for chat list items. Registers its FocusNode with the
/// controller so the adapter can directly requestFocus by index.
class ChatListFocusItem extends StatefulWidget {
  const ChatListFocusItem({
    required this.order,
    required this.controller,
    required this.onFocused,
    required this.child,
    super.key,
  });

  final int order;
  final ChatListController controller;
  final VoidCallback onFocused;
  final Widget child;

  @override
  State<ChatListFocusItem> createState() => _ChatListFocusItemState();
}

class _ChatListFocusItemState extends State<ChatListFocusItem> {
  final FocusNode _focusNode = FocusNode(skipTraversal: true);
  bool _isFocused = false;

  @override
  void dispose() {
    widget.controller.chatListFocusNodes.remove(widget.order);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.chatListFocusNodes[widget.order] = _focusNode;
    final theme = Theme.of(context);
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (focused) {
        if (focused != _isFocused) {
          setState(() => _isFocused = focused);
          if (focused) {
            widget.onFocused();
            Scrollable.ensureVisible(
              context,
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
            );
            Scrollable.ensureVisible(
              context,
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
            );
          }
        }
      },
      child: DecoratedBox(
        decoration: _isFocused
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                color: theme.colorScheme.primary.withOpacity(0.06),
              )
            : const BoxDecoration(),
        child: widget.child,
      ),
    );
  }
}
