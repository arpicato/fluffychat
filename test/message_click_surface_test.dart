import 'package:fluffychat/pages/chat/message_click_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHarness({
    required VoidCallback onSelect,
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
              onReply: onReply,
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('single click selects after the double tap window closes', (tester) async {
    var selectCalls = 0;
    var replyCalls = 0;

    await tester.pumpWidget(
      buildHarness(
        onSelect: () => selectCalls++,
        onReply: () => replyCalls++,
      ),
    );

    await tester.tap(find.byType(MessageClickSurface));
    await tester.pump(kDoubleTapTimeout);

    expect(selectCalls, 1);
    expect(replyCalls, 0);
  });

  testWidgets('double click replies without selecting first', (tester) async {
    var selectCalls = 0;
    var replyCalls = 0;

    await tester.pumpWidget(
      buildHarness(
        onSelect: () => selectCalls++,
        onReply: () => replyCalls++,
      ),
    );

    await tester.tap(find.byType(MessageClickSurface));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(MessageClickSurface));
    await tester.pumpAndSettle();

    expect(selectCalls, 0);
    expect(replyCalls, 1);
  });
}
