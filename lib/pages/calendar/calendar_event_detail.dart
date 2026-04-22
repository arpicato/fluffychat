import 'package:flutter/material.dart';

import 'calendar_event_detail_view.dart';

class CalendarEventDetailPage extends StatefulWidget {
  const CalendarEventDetailPage({
    required this.eventId,
    this.initialTitle,
    this.initialSourceDisplayName,
    super.key,
  });

  final String eventId;
  final String? initialTitle;
  final String? initialSourceDisplayName;

  @override
  State<CalendarEventDetailPage> createState() => CalendarEventDetailController();
}

class CalendarEventDetailController extends State<CalendarEventDetailPage> {
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) => CalendarEventDetailPageView(this);
}

