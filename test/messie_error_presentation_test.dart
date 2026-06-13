import 'package:fluffychat/services/messie_error_presentation.dart';
import 'package:fluffychat/services/messie_error_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns the Messie user-safe message for structured exceptions', () {
    final message = messieUserMessage(
      MessieUserException(
        kind: MessieErrorKind.timeout,
        operation: 'Load todos',
        userMessage: 'Messie took too long to respond. Please try again.',
      ),
      fallback: 'Please try again in a moment.',
    );

    expect(message, 'Messie took too long to respond. Please try again.');
  });

  test('falls back for non-Messie exceptions', () {
    final message = messieUserMessage(
      Exception('raw backend payload'),
      fallback: 'Please try again in a moment.',
    );

    expect(message, 'Please try again in a moment.');
  });

  testWidgets('renders the sanitized message in a simple error panel', (
    tester,
  ) async {
    const fallback = 'Please try again in a moment.';
    final error = MessieUserException(
      kind: MessieErrorKind.server,
      operation: 'Load calendar',
      userMessage:
          'Messie had a problem handling that request. Please try again shortly.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(messieUserMessage(error, fallback: fallback)),
          ),
        ),
      ),
    );

    expect(
      find.text(
        'Messie had a problem handling that request. Please try again shortly.',
      ),
      findsOneWidget,
    );
    expect(find.text(fallback), findsNothing);
  });
}
