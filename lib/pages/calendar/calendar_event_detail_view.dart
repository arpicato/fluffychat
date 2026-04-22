import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/calendar/calendar_event_detail.dart';
import 'package:fluffychat/services/backend_session_service.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CalendarEventDetailPageView extends StatefulWidget {
  const CalendarEventDetailPageView(this.controller, {super.key});

  final CalendarEventDetailController controller;

  @override
  State<CalendarEventDetailPageView> createState() =>
      _CalendarEventDetailPageViewState();
}

class _CalendarEventDetailPageViewState
    extends State<CalendarEventDetailPageView> {
  final MessieCalendarService _calendarService = MessieCalendarService();
  late Future<MessieCalendarEvent> _future;

  CalendarEventDetailPage get _page => widget.controller.widget;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant CalendarEventDetailPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page.eventId != oldWidget.controller.widget.eventId) {
      _future = _load();
    }
  }

  Future<MessieCalendarEvent> _load() async {
    final matrix = Matrix.of(context);
    final session = await BackendSessionService().ensureSession(
      matrix.client,
      matrix.store,
    );
    return _calendarService.getCalendarEventById(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.token,
      eventId: _page.eventId,
    );
  }

  Widget _infoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text(value),
  );

  String _formatDateTime(DateTime value, {required bool allDay}) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final date = '${local.year}-$month-$day';
    if (allDay) return '$date · All day';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$date · $hour:$minute $period';
  }

  void _navigateBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/rooms/calendar');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isColumnMode = FluffyThemes.isColumnMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_page.initialTitle ?? 'Event'),
        automaticallyImplyLeading: false,
        centerTitle: isColumnMode,
        leading: isColumnMode
            ? null
            : BackButton(onPressed: () => _navigateBack(context)),
        actions: [
          if (isColumnMode)
            IconButton(
              onPressed: () => context.go('/rooms/calendar'),
              icon: const Icon(Icons.close),
              tooltip: 'Close',
            ),
        ],
      ),
      body: FutureBuilder<MessieCalendarEvent>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return MaxWidthBody(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_busy_outlined, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load calendar event.',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => setState(() => _future = _load()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final event = snapshot.requireData;
          return MaxWidthBody(
            withScrolling: false,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(
                    event.title.isEmpty ? 'Untitled event' : event.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                  subtitle: Text(event.sourceDisplayName),
                ),
                _infoTile(
                  context: context,
                  icon: Icons.schedule_outlined,
                  label: 'Starts',
                  value: _formatDateTime(event.startsAt, allDay: event.allDay),
                ),
                _infoTile(
                  context: context,
                  icon: Icons.schedule,
                  label: 'Ends',
                  value: _formatDateTime(event.endsAt, allDay: event.allDay),
                ),
                _infoTile(
                  context: context,
                  icon: Icons.public_outlined,
                  label: 'Timezone',
                  value: event.timezone,
                ),
                if (event.location.isNotEmpty)
                  _infoTile(
                    context: context,
                    icon: Icons.place_outlined,
                    label: 'Location',
                    value: event.location,
                  ),
                _infoTile(
                  context: context,
                  icon: Icons.flag_outlined,
                  label: 'Status',
                  value: event.status,
                ),
                if (event.isRecurring)
                  _infoTile(
                    context: context,
                    icon: Icons.repeat_outlined,
                    label: 'Recurrence',
                    value: event.recurrenceRaw!,
                  ),
                if (event.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Description',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                if (event.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(event.description),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
