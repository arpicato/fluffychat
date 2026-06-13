import 'package:fluffychat/pages/chat_list/chat_list_calendar_item.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:flutter_test/flutter_test.dart';

MessieCalendarEvent _eventAt(
  DateTime startsAt, {
  bool allDay = false,
}) => MessieCalendarEvent(
  id: 'event-${startsAt.toIso8601String()}',
  sourceId: 'source-1',
  externalUid: 'external-${startsAt.toIso8601String()}',
  sourceDisplayName: 'Calendar',
  title: 'Test event',
  description: '',
  location: '',
  startsAt: startsAt.toUtc(),
  endsAt: startsAt.toUtc().add(const Duration(hours: 1)),
  allDay: allDay,
  status: 'confirmed',
  timezone: 'UTC',
);

void main() {
  group('ChatListCalendarItem.previewDateLabel', () {
    final now = DateTime(2026, 6, 13, 10, 0);

    test('uses minute precision under one hour', () {
      expect(
        ChatListCalendarItem.previewDateLabel(
          _eventAt(DateTime(2026, 6, 13, 10, 25)),
          now: now,
        ),
        'in 25 minutes',
      );
    });

    test('uses one hour label only for the one-hour interval', () {
      expect(
        ChatListCalendarItem.previewDateLabel(
          _eventAt(DateTime(2026, 6, 13, 11, 0)),
          now: now,
        ),
        'in 1 hour',
      );
    });

    test('uses tomorrow and in 2 days labels only for those day intervals', () {
      expect(
        ChatListCalendarItem.previewDateLabel(
          _eventAt(DateTime(2026, 6, 14, 9, 0)),
          now: now,
        ),
        'tomorrow',
      );
      expect(
        ChatListCalendarItem.previewDateLabel(
          _eventAt(DateTime(2026, 6, 15, 9, 0)),
          now: now,
        ),
        'in 2 days',
      );
    });

    test('falls back to absolute date and time for other intervals', () {
      expect(
        ChatListCalendarItem.previewDateLabel(
          _eventAt(DateTime(2026, 6, 16, 9, 0)),
          now: now,
        ),
        '06/16 · 9:00 AM',
      );
      expect(
        ChatListCalendarItem.previewDateLabel(
          _eventAt(DateTime(2026, 6, 13, 13, 0)),
          now: now,
        ),
        '06/13 · 1:00 PM',
      );
    });
  });
}
