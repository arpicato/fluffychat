import 'dart:async';

import 'package:flutter/material.dart';

class MessageClickSurface extends StatefulWidget {
  const MessageClickSurface({
    super.key,
    required this.onSelect,
    required this.onDeselect,
    required this.onReply,
    required this.child,
    this.behavior = HitTestBehavior.deferToChild,
  });

  final VoidCallback onSelect;
  final VoidCallback onDeselect;
  final VoidCallback onReply;
  final Widget child;
  final HitTestBehavior behavior;

  @override
  State<MessageClickSurface> createState() => _MessageClickSurfaceState();
}

class _MessageClickSurfaceState extends State<MessageClickSurface> {
  static const Duration _selectionDelay = Duration(milliseconds: 70);

  Timer? _pendingSelectTimer;
  bool _selectionCommitted = false;

  @override
  void dispose() {
    _pendingSelectTimer?.cancel();
    super.dispose();
  }

  void _handleTapUp(TapUpDetails details) {
    _pendingSelectTimer?.cancel();
    _pendingSelectTimer = Timer(_selectionDelay, () {
      _selectionCommitted = true;
      widget.onSelect();
    });
  }

  void _handleDoubleTap() {
    _pendingSelectTimer?.cancel();
    if (_selectionCommitted) {
      widget.onDeselect();
      _selectionCommitted = false;
    }
    widget.onReply();
  }

  void _handleTapCancel() {
    _pendingSelectTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: widget.behavior,
      onPointerUp: (event) => _handleTapUp(
        TapUpDetails(
          globalPosition: event.position,
          localPosition: event.localPosition,
          kind: event.kind,
        ),
      ),
      onPointerCancel: (_) => _handleTapCancel(),
      child: GestureDetector(
        behavior: widget.behavior,
        onDoubleTap: _handleDoubleTap,
        child: widget.child,
      ),
    );
  }
}
