import 'package:fluffychat/pages/chat/message_selection_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageSelectionCoordinator', () {
    test('selection happens within 16ms of click', () async {
      final stopwatch = Stopwatch();
      Duration? selectedAt;
      final coordinator = MessageSelectionCoordinator(
        scheduleSelection: (_) {
          selectedAt = stopwatch.elapsed;
        },
        onReply: (_) {},
      );

      stopwatch.start();
      coordinator.handleTapDown('event-1');
      await Future<void>.delayed(const Duration(milliseconds: 17));

      expect(selectedAt, isNotNull);
      expect(selectedAt!, lessThanOrEqualTo(const Duration(milliseconds: 16)));

      coordinator.dispose();
    });

    test('clicking next to second message selects the second message', () async {
      final selections = <String>[];
      final coordinator = MessageSelectionCoordinator(
        scheduleSelection: selections.add,
        onReply: (_) {},
      );

      coordinator.handleTapDown('event-1');
      await Future<void>.delayed(coordinator.selectionCommitDelay * 2);
      coordinator.handleTapDown('event-2');
      await Future<void>.delayed(coordinator.selectionCommitDelay * 2);

      expect(selections, ['event-1', 'event-2']);

      coordinator.dispose();
    });

    test('clicking next to a selected message deselects it', () async {
      final selected = <String>{};
      final coordinator = MessageSelectionCoordinator(
        scheduleSelection: (eventId) {
          if (!selected.add(eventId)) {
            selected.remove(eventId);
          }
        },
        onReply: (_) {},
      );

      coordinator.handleTapDown('event-1');
      await Future<void>.delayed(coordinator.selectionCommitDelay * 2);
      expect(selected, {'event-1'});

      coordinator.handleTapDown('event-1');
      await Future<void>.delayed(coordinator.selectionCommitDelay * 2);

      expect(selected, isEmpty);

      coordinator.dispose();
    });
  });
}
