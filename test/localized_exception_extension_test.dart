import 'package:fluffychat/services/messie_error_service.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MessieUserException uses user-safe localized string', (
    tester,
  ) async {
    late BuildContext capturedContext;
    final error = MessieUserException(
      kind: MessieErrorKind.rateLimited,
      operation: 'Save sticker',
      userMessage: 'Saved sticker limit reached.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const Placeholder();
          },
        ),
      ),
    );

    expect(
      error.toLocalizedString(capturedContext),
      'Saved sticker limit reached.',
    );
  });
}
