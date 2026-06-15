import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
  static const Duration _selectionDelay = Duration(milliseconds: 150);

  Timer? _pendingSelectTimer;
  bool _selectionCommitted = false;
  DateTime? _lastTapUpAt;
  bool _doubleTapInProgress = false;

  @override
  void dispose() {
    _pendingSelectTimer?.cancel();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_selectionCommitted) {
      return;
    }

    final lastTapUpAt = _lastTapUpAt;
    if (lastTapUpAt == null) {
      return;
    }

    if (DateTime.now().difference(lastTapUpAt) <= kDoubleTapTimeout) {
      _pendingSelectTimer?.cancel();
      _doubleTapInProgress = true;
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_selectionCommitted) {
      _pendingSelectTimer?.cancel();
      _doubleTapInProgress = false;
      _lastTapUpAt = null;
      widget.onDeselect();
      _selectionCommitted = false;
      return;
    }

    if (_doubleTapInProgress) {
      _doubleTapInProgress = false;
      _lastTapUpAt = null;
      widget.onReply();
      return;
    }

    _pendingSelectTimer?.cancel();
    _lastTapUpAt = DateTime.now();
    _pendingSelectTimer = Timer(_selectionDelay, () {
      _selectionCommitted = true;
      _lastTapUpAt = null;
      widget.onSelect();
    });
  }

  void _handleTapCancel() {
    _pendingSelectTimer?.cancel();
    _doubleTapInProgress = false;
    _lastTapUpAt = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: widget.behavior,
      onPointerDown: _handlePointerDown,
      onPointerUp: (event) => _handleTapUp(
        TapUpDetails(
          globalPosition: event.position,
          localPosition: event.localPosition,
          kind: event.kind,
        ),
      ),
      onPointerCancel: (_) => _handleTapCancel(),
      child: widget.child,
    );
  }
}
