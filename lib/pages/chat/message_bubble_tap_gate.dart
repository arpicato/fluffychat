import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:fluffychat/pages/chat/message_text_hit.dart';

/// Wraps message bubble content so that taps on empty space inside the bubble
/// (e.g. to the right of a short line) trigger message-level select/reply,
/// while taps on actual text glyphs are left to the ancestor [SelectionArea]
/// for word selection.
///
/// This uses a translucent [Listener] (which sits outside the gesture arena)
/// so it can react even though the surrounding SelectableRegion claims the
/// gesture. On a glyph hit the gate stays inert and lets text selection win.
class MessageBubbleTapGate extends StatefulWidget {
  const MessageBubbleTapGate({
    super.key,
    required this.onSelect,
    required this.onDeselect,
    required this.onReply,
    required this.child,
    this.enabled = true,
    this.probeAt,
  });

  /// When false the gate is a passthrough (no tap handling at all). Used to
  /// restrict tap-to-select/reply to text bubbles on pointer (desktop/web)
  /// platforms; mobile and non-text bubbles disable it.
  final bool enabled;

  final VoidCallback onSelect;
  final VoidCallback onDeselect;
  final VoidCallback onReply;
  final Widget child;

  /// Test seam: overrides the real render-tree text probe.
  final SubtreeTextProbe Function(Offset globalPosition)? probeAt;

  @override
  State<MessageBubbleTapGate> createState() => _MessageBubbleTapGateState();
}

class _MessageBubbleTapGateState extends State<MessageBubbleTapGate> {
  static const Duration _selectionDelay = Duration(milliseconds: 150);

  final GlobalKey _childKey = GlobalKey();

  Timer? _pendingSelectTimer;
  bool _selectionCommitted = false;
  DateTime? _lastTapUpAt;
  bool _doubleTapInProgress = false;
  bool _downHandled = false;

  @override
  void dispose() {
    _pendingSelectTimer?.cancel();
    super.dispose();
  }

  SubtreeTextProbe _probe(Offset globalPosition) {
    final override = widget.probeAt;
    if (override != null) {
      return override(globalPosition);
    }
    final renderObject = _childKey.currentContext?.findRenderObject();
    if (renderObject == null) {
      return const SubtreeTextProbe(hasParagraph: false, glyphHit: false);
    }
    return probeSubtreeText(renderObject, globalPosition);
  }

  void _handlePointerDown(PointerDownEvent event) {
    final probe = _probe(event.position);
    // Only handle empty-space taps inside text bubbles. On a glyph, defer to
    // the ancestor SelectionArea. In non-text bubbles (no paragraphs, e.g.
    // images/video/files) stay inert so the content's own taps work.
    _downHandled = probe.hasParagraph && !probe.glyphHit;
    if (!_downHandled) {
      _pendingSelectTimer?.cancel();
      _doubleTapInProgress = false;
      _lastTapUpAt = null;
      return;
    }

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

  void _handlePointerUp(PointerUpEvent event) {
    if (!_downHandled) {
      return;
    }

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

  void _handlePointerCancel(PointerCancelEvent event) {
    _pendingSelectTimer?.cancel();
    _doubleTapInProgress = false;
    _lastTapUpAt = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: KeyedSubtree(key: _childKey, child: widget.child),
    );
  }
}
