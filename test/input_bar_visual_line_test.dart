import 'package:fluffychat/pages/chat/input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

class _FakeRoom extends Fake implements Room {}

void main() {
  testWidgets('isCaretOnTopVisualLine detects first visual line', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'short');
    final focusNode = FocusNode();
    final editableKey = GlobalKey<EditableTextState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: EditableText(
              key: editableKey,
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
              cursorColor: Colors.blue,
              backgroundCursorColor: Colors.grey,
              maxLines: 8,
            ),
          ),
        ),
      ),
    );

    controller.selection = const TextSelection.collapsed(offset: 0);
    await tester.pump();

    expect(
      isCaretOnTopVisualLine(
        editableTextState: editableKey.currentState!,
        selection: controller.selection,
      ),
      isTrue,
    );
  });

  testWidgets('isCaretOnTopVisualLine detects wrapped lower visual line', (
    tester,
  ) async {
    final controller = TextEditingController(
      text: 'This is a very long line that should soft wrap in a narrow field.',
    );
    final focusNode = FocusNode();
    final editableKey = GlobalKey<EditableTextState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: EditableText(
              key: editableKey,
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
              cursorColor: Colors.blue,
              backgroundCursorColor: Colors.grey,
              maxLines: 8,
            ),
          ),
        ),
      ),
    );

    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    await tester.pump();

    expect(
      isCaretOnTopVisualLine(
        editableTextState: editableKey.currentState!,
        selection: controller.selection,
      ),
      isFalse,
    );
  });

  testWidgets('InputBar reports false when caret is on wrapped lower visual line', (
    tester,
  ) async {
    final controller = TextEditingController(
      text: 'This is a very long line that should soft wrap in a narrow field.',
    );
    final focusNode = FocusNode();
    bool? reportedTopVisualLine;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: InputBar(
              room: _FakeRoom(),
              minLines: 1,
              maxLines: 8,
              autofocus: false,
              keyboardType: TextInputType.multiline,
              focusNode: focusNode,
              controller: controller,
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (_) {},
              onCaretTopVisualLineChanged: (value) {
                reportedTopVisualLine = value;
              },
              suggestionEmojis: const [],
            ),
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    await tester.pump();
    await tester.pump();

    expect(reportedTopVisualLine, isFalse);
  });
}
