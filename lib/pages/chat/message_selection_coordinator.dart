import 'dart:async';

class MessageSelectionCoordinator {
  MessageSelectionCoordinator({
    required this.scheduleSelection,
    required this.onReply,
    Duration? selectionCommitDelay,
    Duration? doubleTapWindow,
    DateTime Function()? now,
  }) : _selectionCommitDelay =
           selectionCommitDelay ?? Duration.zero,
       _doubleTapWindow = doubleTapWindow ?? const Duration(milliseconds: 220),
       _now = now ?? DateTime.now;

  final void Function(String eventId) scheduleSelection;
  final void Function(String eventId) onReply;
  final Duration _selectionCommitDelay;
  final Duration _doubleTapWindow;
  final DateTime Function() _now;

  Timer? _pendingSelectionTimer;
  String? _pendingSelectionEventId;
  String? _lastTappedEventId;
  DateTime? _lastTapAt;
  bool _lastTapCommittedSelection = false;

  Duration get selectionCommitDelay => _selectionCommitDelay;

  void dispose() {
    _pendingSelectionTimer?.cancel();
  }

  void handleTapDown(String eventId) {
    _pendingSelectionTimer?.cancel();

    final now = _now();
    final isDoubleTap =
        _lastTappedEventId == eventId &&
        _lastTapAt != null &&
        now.difference(_lastTapAt!) <= _doubleTapWindow &&
        !_lastTapCommittedSelection;

    _lastTappedEventId = eventId;
    _lastTapAt = now;

    if (isDoubleTap) {
      _pendingSelectionEventId = null;
      _lastTapCommittedSelection = false;
      onReply(eventId);
      return;
    }

    _pendingSelectionEventId = eventId;
    _pendingSelectionTimer = Timer(_selectionCommitDelay, () {
      if (_pendingSelectionEventId != eventId) return;
      _lastTapCommittedSelection = true;
      scheduleSelection(eventId);
      _pendingSelectionEventId = null;
    });
  }
}
