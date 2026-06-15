import 'dart:async';

import 'package:flutter/material.dart';

class MessageClickSurface extends StatefulWidget {
  const MessageClickSurface({
    super.key,
    required this.onSelect,
    required this.onReply,
    required this.child,
    this.behavior = HitTestBehavior.deferToChild,
  });

  final VoidCallback onSelect;
  final VoidCallback onReply;
  final Widget child;
  final HitTestBehavior behavior;

  @override
  State<MessageClickSurface> createState() => _MessageClickSurfaceState();
}

class _MessageClickSurfaceState extends State<MessageClickSurface> {
  bool _doubleTapTriggered = false;

  void _handleTap() {
    _doubleTapTriggered = false;
    widget.onSelect();
  }

  void _handleDoubleTap() {
    _doubleTapTriggered = true;
    widget.onReply();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: _handleTap,
      onDoubleTap: _handleDoubleTap,
      child: widget.child,
    );
  }
}
