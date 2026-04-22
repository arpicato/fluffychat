import 'package:fluffychat/pages/calendar/calendar_event_display.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calendarEventDisplayRange', () {
    test('treats all-day midnight end as exclusive without local tz shift', () {
      final event = MessieCalendarEvent(
        id: 'event-1',
        sourceId: 'source-1',
        externalUid: 'uid-1',
        title: 'Good Friday',
        description: '',
        location: '',
        startsAt: DateTime.utc(2026, 4, 3),
        endsAt: DateTime.utc(2026, 4, 4),
        allDay: true,
        status: 'confirmed',
        timezone: 'UTC',
        sourceDisplayName: 'Holidays',
      );

      final range = calendarEventDisplayRange(event);

      expect(range.start.year, 2026);
      expect(range.start.month, 4);
      expect(range.start.day, 3);
      expect(range.start.hour, 0);
      expect(range.end.year, 2026);
      expect(range.end.month, 4);
      expect(range.end.day, 3);
      expect(range.end.hour, 23);
    });

    test('keeps timed event end unchanged', () {
      final event = MessieCalendarEvent(
        id: 'event-2',
        sourceId: 'source-1',
        externalUid: 'uid-2',
        title: 'Meeting',
        description: '',
        location: '',
        startsAt: DateTime.utc(2026, 4, 3, 15),
        endsAt: DateTime.utc(2026, 4, 3, 16),
        allDay: false,
        status: 'confirmed',
        timezone: 'UTC',
        sourceDisplayName: 'Work',
      );

      final range = calendarEventDisplayRange(event);

      expect(range.start, DateTime.utc(2026, 4, 3, 15).toLocal());
      expect(range.end, DateTime.utc(2026, 4, 3, 16).toLocal());
    });
  });
}
