import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Ctrl+Enter submits create todo list dialog', (tester) async {
    bool? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  dialogResult = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => CallbackShortcuts(
                      bindings: {
                        const SingleActivator(
                          LogicalKeyboardKey.enter,
                          control: true,
                        ): () {
                          Navigator.of(dialogContext).pop(true);
                        },
                      },
                      child: AlertDialog(
                        title: const Text('Create todo list'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            TextField(
                              autofocus: true,
                              decoration: InputDecoration(labelText: 'Title'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Create todo list'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'New list');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.text('Create todo list'), findsNothing);
    expect(dialogResult, isTrue);
  });
}
