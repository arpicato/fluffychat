import 'package:flutter/material.dart';

class ChatListContextMenuRegion extends StatelessWidget {
  const ChatListContextMenuRegion({
    required this.child,
    required this.onShowContextMenu,
    super.key,
  });

  final Widget child;
  final void Function(BuildContext context) onShowContextMenu;

  @override
  Widget build(BuildContext context) => Builder(
    builder: (context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => onShowContextMenu(context),
      onSecondaryTapDown: (_) => onShowContextMenu(context),
      child: child,
    ),
  );
}
