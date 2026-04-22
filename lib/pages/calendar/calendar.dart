import 'package:flutter/material.dart';

import 'calendar_view.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => CalendarPageController();
}

class CalendarPageController extends State<CalendarPage> {
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) => CalendarPageView(this);
}

