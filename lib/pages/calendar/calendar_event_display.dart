import 'package:fluffychat/services/messie_calendar_service.dart';

class CalendarEventDisplayRange {
  const CalendarEventDisplayRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}

CalendarEventDisplayRange calendarEventDisplayRange(
  MessieCalendarEvent event,
) {
  if (event.allDay) {
    final startUtc = event.startsAt.toUtc();
    final endUtc = event.endsAt.toUtc();
    final start = DateTime(startUtc.year, startUtc.month, startUtc.day);
    var end = DateTime(endUtc.year, endUtc.month, endUtc.day);

    if (!end.isAfter(start)) {
      end = start.add(const Duration(days: 1));
    }

    if (end.hour == 0 &&
        end.minute == 0 &&
        end.second == 0 &&
        end.millisecond == 0 &&
        end.microsecond == 0) {
      end = end.subtract(const Duration(microseconds: 1));
    }

    return CalendarEventDisplayRange(start: start, end: end);
  }

  final start = event.startsAt.toLocal();
  var end = event.endsAt.toLocal();

  if (!end.isAfter(start)) {
    end = start.add(const Duration(minutes: 1));
  }

  return CalendarEventDisplayRange(start: start, end: end);
}
