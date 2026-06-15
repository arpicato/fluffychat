import 'package:flutter/material.dart';

/// Wraps a message in a Focus node for keyboard traversal.
/// Internal focusables (buttons, links) are isolated in their own
/// FocusTraversalGroup so arrow-key traversal skips them.
class MessageFocusWrapper extends StatefulWidget {
  const MessageFocusWrapper({
    super.key,
    required this.order,
    required this.onFocused,
    required this.child,
  });

  final int order;
  final VoidCallback onFocused;
  final Widget child;

  @override
  State<MessageFocusWrapper> createState() => _MessageFocusWrapperState();
}

class _MessageFocusWrapperState extends State<MessageFocusWrapper> {
  final FocusNode _focusNode = FocusNode(skipTraversal: false);
  bool _isFocused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FocusTraversalOrder(
      order: NumericFocusOrder(widget.order.toDouble()),
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (focused) {
          if (focused != _isFocused) {
            setState(() => _isFocused = focused);
            if (focused) {
              widget.onFocused();
            }
          }
        },
        child: FocusTraversalGroup(
          descendantsAreFocusable: true,
          descendantsAreTraversable: false,
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
        ),
      ),
    );
  }
}
