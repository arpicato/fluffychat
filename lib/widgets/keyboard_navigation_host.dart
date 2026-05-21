import 'package:fluffychat/utils/keyboard/app_shortcuts.dart';
import 'package:fluffychat/utils/keyboard/keyboard_navigation.dart';
import 'package:flutter/material.dart';

/// Provides keyboard navigation state and global shortcut handling
/// to the widget tree. Sits above the router so all pages can access it.
class KeyboardNavigationHost extends StatefulWidget {
  const KeyboardNavigationHost({super.key, required this.child});

  final Widget child;

  @override
  State<KeyboardNavigationHost> createState() => _KeyboardNavigationHostState();
}

class _KeyboardNavigationHostState extends State<KeyboardNavigationHost> {
  final _keyboardNavState = KeyboardNavigationState();

  @override
  void dispose() {
    _keyboardNavState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardNavigation(
      state: _keyboardNavState,
      child: widget.child,
    );
  }
}
