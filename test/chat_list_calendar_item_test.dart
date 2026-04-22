import 'package:fluffychat/pages/chat_list/chat_list_calendar_item.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatListCalendarItem renders date in subtitle and time in title', (
    tester,
  ) async {
    final event = MessieCalendarEvent(
      id: 'event-1',
      sourceId: 'source-1',
      externalUid: 'uid-1',
      title: 'Planning',
      description: 'Sprint planning',
      location: 'Room 1',
      startsAt: DateTime.utc(2026, 4, 22, 15, 30),
      endsAt: DateTime.utc(2026, 4, 22, 16, 30),
      allDay: false,
      status: 'CONFIRMED',
      timezone: 'UTC',
      sourceDisplayName: 'Work',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatListCalendarItem(event: event, onTap: () {}),
        ),
      ),
    );

    final localStart = event.startsAt.toLocal();
    final expectedDate =
        '${localStart.month.toString().padLeft(2, '0')}/${localStart.day.toString().padLeft(2, '0')}';

    expect(find.text('Planning'), findsOneWidget);
    expect(find.textContaining('Work'), findsOneWidget);
    expect(find.textContaining(expectedDate), findsOneWidget);
    expect(find.text('3:30 PM'), findsOneWidget);
  });
}
