import 'package:flutter/material.dart';

/// A subtle visual indicator for keyboard-focused items.
/// Used on chat list items and message bubbles to show which
/// item is currently selected via keyboard navigation.
class FocusHighlight extends StatelessWidget {
  const FocusHighlight({
    super.key,
    required this.isFocused,
    required this.child,
  });

  final bool isFocused;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isFocused) return child;

    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 3,
          ),
        ),
        color: theme.colorScheme.primary.withOpacity(0.06),
      ),
      child: child,
    );
  }
}
