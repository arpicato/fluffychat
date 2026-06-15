import 'package:fluffychat/pages/chat/message_click_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHarness({
    required VoidCallback onSelect,
    required VoidCallback onDeselect,
    required VoidCallback onReply,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            height: 80,
            child: MessageClickSurface(
              onSelect: onSelect,
              onDeselect: onDeselect,
              onReply: onReply,
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('single click selects within 200ms', (tester) async {
    var selectCalls = 0;
    var deselectCalls = 0;
    var replyCalls = 0;

    await tester.pumpWidget(
      buildHarness(
        onSelect: () => selectCalls++,
        onDeselect: () => deselectCalls++,
        onReply: () => replyCalls++,
      ),
    );

    await tester.tap(find.byType(MessageClickSurface));
    await tester.pump(const Duration(milliseconds: 200));

    expect(selectCalls, 1);
    expect(deselectCalls, 0);
    expect(replyCalls, 0);
  });

  testWidgets('double click replies without selecting first', (tester) async {
    var selectCalls = 0;
    var deselectCalls = 0;
    var replyCalls = 0;

    await tester.pumpWidget(
      buildHarness(
        onSelect: () => selectCalls++,
        onDeselect: () => deselectCalls++,
        onReply: () => replyCalls++,
      ),
    );

    await tester.tap(find.byType(MessageClickSurface));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(MessageClickSurface));
    await tester.pumpAndSettle();

    expect(selectCalls, 0);
    expect(deselectCalls, 0);
    expect(replyCalls, 1);
  });

  testWidgets('selected message deselects immediately on next click', (tester) async {
    var selected = false;
    var replyCalls = 0;

    await tester.pumpWidget(
      buildHarness(
        onSelect: () => selected = !selected,
        onDeselect: () => selected = false,
        onReply: () => replyCalls++,
      ),
    );

    await tester.tap(find.byType(MessageClickSurface));
    await tester.pump(const Duration(milliseconds: 200));
    expect(selected, isTrue);

    await tester.tap(find.byType(MessageClickSurface));
    await tester.pump();
    await tester.pump(kDoubleTapTimeout);

    expect(selected, isFalse);
    expect(replyCalls, 0);
  });

  testWidgets('selected message does not wait for double click before deselecting', (tester) async {
    var selected = false;
    var replyCalls = 0;

    await tester.pumpWidget(
      buildHarness(
        onSelect: () => selected = true,
        onDeselect: () => selected = false,
        onReply: () => replyCalls++,
      ),
    );

    await tester.tap(find.byType(MessageClickSurface));
    await tester.pump(const Duration(milliseconds: 200));
    expect(selected, isTrue);

    await tester.tap(find.byType(MessageClickSurface));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(MessageClickSurface));
    await tester.pumpAndSettle();

    expect(selected, isFalse);
    expect(replyCalls, 0);
  });
}
