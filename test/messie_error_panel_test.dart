import 'package:fluffychat/services/messie_error_service.dart';
import 'package:fluffychat/widgets/messie_error_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a structured Messie error message and retry button', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessieErrorPanel(
            title: 'Could not load todos from Messie.',
            icon: Icons.cloud_off_outlined,
            error: MessieUserException(
              kind: MessieErrorKind.timeout,
              operation: 'Load todos',
              userMessage: 'Messie took too long to respond. Please try again.',
            ),
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Could not load todos from Messie.'), findsOneWidget);
    expect(
      find.text('Messie took too long to respond. Please try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('falls back to a safe generic message for non-Messie errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessieErrorPanel(
            title: 'Could not load bridge connections.',
            icon: Icons.link_off_outlined,
            error: Exception('raw html payload'),
            onRetry: _noopRetry,
          ),
        ),
      ),
    );

    expect(find.text('Could not load bridge connections.'), findsOneWidget);
    expect(find.text('Please try again in a moment.'), findsOneWidget);
    expect(find.textContaining('raw html payload'), findsNothing);
  });
}

void _noopRetry() {}
