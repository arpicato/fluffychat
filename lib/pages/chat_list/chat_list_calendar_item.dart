import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:fluffychat/widgets/hover_builder.dart';
import 'package:flutter/material.dart';

import '../../config/themes.dart';

class ChatListCalendarItem extends StatelessWidget {
  const ChatListCalendarItem({
    required this.event,
    required this.onTap,
    this.active = false,
    super.key,
  });

  final MessieCalendarEvent event;
  final VoidCallback onTap;
  final bool active;

  static String previewDateLabel(
    MessieCalendarEvent event, {
    DateTime? now,
  }) {
    final localStart = event.startsAt.toLocal();
    final nowLocal = (now ?? DateTime.now()).toLocal();
    final today = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final startDay = DateTime(localStart.year, localStart.month, localStart.day);
    final dayDelta = startDay.difference(today).inDays;

    if (dayDelta == 0) {
      final minuteDelta = localStart.difference(nowLocal).inMinutes;
      if (minuteDelta > 0 && minuteDelta < 60) {
        return 'in $minuteDelta minutes';
      }
      final hourDelta = localStart.difference(nowLocal).inHours;
      if (hourDelta == 1) {
        return 'in 1 hour';
      }
    }

    if (dayDelta == 1) return 'tomorrow';
    if (dayDelta == 2) return 'in 2 days';

    final month = localStart.month.toString().padLeft(2, '0');
    final day = localStart.day.toString().padLeft(2, '0');
    if (event.allDay) return '$month/$day';
    return '$month/$day · ${previewTimeLabel(event)}';
  }

  static String previewTimeLabel(MessieCalendarEvent event) {
    final localStart = event.startsAt.toLocal();
    if (event.allDay) return 'All day';
    final hour = localStart.hour % 12 == 0 ? 12 : localStart.hour % 12;
    final minute = localStart.minute.toString().padLeft(2, '0');
    final period = localStart.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _timeLabel() {
    return previewTimeLabel(event);
  }

  String _dateLabel() {
    return previewDateLabel(event);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = active
        ? theme.colorScheme.secondaryContainer
        : null;
    final description = event.description.trim();
    final subtitleParts = <String>[
      _dateLabel(),
      if (event.sourceDisplayName.trim().isNotEmpty) event.sourceDisplayName,
      if (description.isNotEmpty) description,
      if (description.isEmpty && event.location.trim().isNotEmpty)
        event.location,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        clipBehavior: Clip.hardEdge,
        color: backgroundColor,
        child: HoverBuilder(
          builder: (context, hovered) => ListTile(
            visualDensity: const VisualDensity(vertical: -0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            onTap: onTap,
            leading: AnimatedScale(
              duration: FluffyThemes.animationDuration,
              curve: FluffyThemes.animationCurve,
              scale: hovered ? 1.1 : 1.0,
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: const Icon(Icons.event_outlined),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    event.title.isEmpty ? 'Untitled event' : event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      _timeLabel(),
                      style: theme.textTheme.bodySmall,
                    ),
                ),
              ],
            ),
            subtitle: Text(
              subtitleParts.join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
