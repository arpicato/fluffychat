import 'package:fluffychat/services/messie_error_presentation.dart';
import 'package:flutter/material.dart';

class MessieErrorPanel extends StatelessWidget {
  const MessieErrorPanel({
    required this.title,
    required this.icon,
    required this.error,
    required this.onRetry,
    this.fallbackMessage = 'Please try again in a moment.',
    this.titleStyle,
    this.iconSize = 48,
    this.messageSpacing = 8,
    super.key,
  });

  final String title;
  final IconData icon;
  final Object? error;
  final VoidCallback onRetry;
  final String fallbackMessage;
  final TextStyle? titleStyle;
  final double iconSize;
  final double messageSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize),
            const SizedBox(height: 16),
            Text(
              title,
              style: titleStyle ?? theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: messageSpacing),
            Text(
              messieUserMessage(error, fallback: fallbackMessage),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
