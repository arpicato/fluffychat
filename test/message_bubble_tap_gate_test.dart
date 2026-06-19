import 'package:fluffychat/pages/chat/message_bubble_tap_gate.dart';
import 'package:fluffychat/pages/chat/message_text_hit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget harness({
    required SubtreeTextProbe Function(Offset) probeAt,
    required VoidCallback onSelect,
    required VoidCallback onDeselect,
    required VoidCallback onReply,
    bool enabled = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SelectionArea(
          child: Center(
            child: SizedBox(
              width: 300,
              height: 100,
              child: MessageBubbleTapGate(
                enabled: enabled,
                probeAt: probeAt,
                onSelect: onSelect,
                onDeselect: onDeselect,
                onReply: onReply,
                child: const ColoredBox(
                  color: Color(0xFFCCCCCC),
                  child: SizedBox.expand(
                    child: Text(
                      'hi\nthis is a longer line',
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  const emptyTextProbe =
      SubtreeTextProbe(hasParagraph: true, glyphHit: false); // text bubble, empty spot
  const glyphProbe =
      SubtreeTextProbe(hasParagraph: true, glyphHit: true); // on a glyph
  const noTextProbe =
      SubtreeTextProbe(hasParagraph: false, glyphHit: false); // image/video/file

  testWidgets('single tap on empty space in text bubble selects', (tester) async {
    var selectCalls = 0, deselectCalls = 0, replyCalls = 0;
    await tester.pumpWidget(
      harness(
        probeAt: (_) => emptyTextProbe,
        onSelect: () => selectCalls++,
        onDeselect: () => deselectCalls++,
        onReply: () => replyCalls++,
      ),
    );

    await tester.tapAt(tester.getCenter(find.byType(MessageBubbleTapGate)));
    await tester.pump(const Duration(milliseconds: 200));

    expect(selectCalls, 1);
    expect(replyCalls, 0);
    expect(deselectCalls, 0);
  });

  testWidgets('double tap on empty space replies, no select', (tester) async {
    var selectCalls = 0, replyCalls = 0;
    await tester.pumpWidget(
      harness(
        probeAt: (_) => emptyTextProbe,
        onSelect: () => selectCalls++,
        onDeselect: () {},
        onReply: () => replyCalls++,
      ),
    );

    final p = tester.getCenter(find.byType(MessageBubbleTapGate));
    await tester.tapAt(p);
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tapAt(p);
    await tester.pumpAndSettle();

    expect(replyCalls, 1);
    expect(selectCalls, 0);
  });

  testWidgets('tap on a glyph does NOT select or reply', (tester) async {
    var selectCalls = 0, replyCalls = 0;
    await tester.pumpWidget(
      harness(
        probeAt: (_) => glyphProbe,
        onSelect: () => selectCalls++,
        onDeselect: () {},
        onReply: () => replyCalls++,
      ),
    );

    final p = tester.getCenter(find.byType(MessageBubbleTapGate));
    await tester.tapAt(p);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tapAt(p);
    await tester.pump(const Duration(milliseconds: 200));

    expect(selectCalls, 0, reason: 'glyph taps should be left to SelectionArea');
    expect(replyCalls, 0, reason: 'glyph taps should be left to SelectionArea');
  });

  testWidgets('tap on non-text bubble (image) is inert', (tester) async {
    var selectCalls = 0, replyCalls = 0;
    await tester.pumpWidget(
      harness(
        probeAt: (_) => noTextProbe,
        onSelect: () => selectCalls++,
        onDeselect: () {},
        onReply: () => replyCalls++,
      ),
    );

    final p = tester.getCenter(find.byType(MessageBubbleTapGate));
    await tester.tapAt(p);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tapAt(p);
    await tester.pump(const Duration(milliseconds: 200));

    expect(selectCalls, 0, reason: 'image/video/file bubbles have no text; gate must stay inert');
    expect(replyCalls, 0, reason: 'image/video/file bubbles have no text; gate must stay inert');
  });

  testWidgets('disabled gate ignores taps even on empty text space', (tester) async {
    var selectCalls = 0, replyCalls = 0;
    await tester.pumpWidget(
      harness(
        enabled: false,
        probeAt: (_) => emptyTextProbe,
        onSelect: () => selectCalls++,
        onDeselect: () {},
        onReply: () => replyCalls++,
      ),
    );

    final p = tester.getCenter(find.byType(MessageBubbleTapGate));
    await tester.tapAt(p);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tapAt(p);
    await tester.pump(const Duration(milliseconds: 200));

    expect(selectCalls, 0, reason: 'disabled gate (mobile / non-text) must not select');
    expect(replyCalls, 0, reason: 'disabled gate (mobile / non-text) must not reply');
  });
}
