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

  String _timeLabel(BuildContext context) {
    final localStart = event.startsAt.toLocal();
    if (event.allDay) return 'All day';
    final hour = localStart.hour % 12 == 0 ? 12 : localStart.hour % 12;
    final minute = localStart.minute.toString().padLeft(2, '0');
    final period = localStart.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _dateLabel() {
    final localStart = event.startsAt.toLocal();
    final month = localStart.month.toString().padLeft(2, '0');
    final day = localStart.day.toString().padLeft(2, '0');
    return '$month/$day';
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
                    _timeLabel(context),
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
