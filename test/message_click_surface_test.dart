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

  testWidgets('single click selects within 170ms', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 170));

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

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MessageClickSurface)),
    );
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 40));

    final secondGesture = await tester.startGesture(
      tester.getCenter(find.byType(MessageClickSurface)),
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(selectCalls, 0);

    await secondGesture.up();
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
    await tester.pump(const Duration(milliseconds: 170));
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
    await tester.pump(const Duration(milliseconds: 170));
    expect(selected, isTrue);

    await tester.tap(find.byType(MessageClickSurface));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(MessageClickSurface));
    await tester.pumpAndSettle();

    expect(selected, isFalse);
    expect(replyCalls, 0);
  });

  testWidgets('tap on interactive child does not trigger selection', (tester) async {
    var selectCalls = 0;
    var childTapCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MessageClickSurface(
                      onSelect: () => selectCalls++,
                      onDeselect: () {},
                      onReply: () {},
                      behavior: HitTestBehavior.opaque,
                      child: const Material(color: Colors.transparent),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => childTapCalls++,
                    child: Container(
                      width: 200,
                      height: 40,
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: const Text('tap me'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('tap me'));
    await tester.pump(const Duration(milliseconds: 170));

    expect(childTapCalls, 1);
    expect(selectCalls, 0);
  });

  testWidgets('tap on empty area around interactive child still selects', (tester) async {
    var selectCalls = 0;
    var childTapCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MessageClickSurface(
                      onSelect: () => selectCalls++,
                      onDeselect: () {},
                      onReply: () {},
                      behavior: HitTestBehavior.opaque,
                      child: const Material(color: Colors.transparent),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    width: 100,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => childTapCalls++,
                      child: Container(
                        color: Colors.red,
                        alignment: Alignment.center,
                        child: const Text('tap me'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Tap at (500, 300) — inside the 300x100 Stack (centered at 400,300 → spans 250..550,250..350)
    // but outside the 100x40 Positioned child (at 250,250..350,290)
    await tester.tapAt(const Offset(500, 300));
    await tester.pump(const Duration(milliseconds: 170));

    expect(childTapCalls, 0);
    expect(selectCalls, 1);
  });

  testWidgets('Stack background overlay does not fire when child handles tap', (tester) async {
    var selectCalls = 0;
    var childTapCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MessageClickSurface(
                      onSelect: () => selectCalls++,
                      onDeselect: () {},
                      onReply: () {},
                      behavior: HitTestBehavior.opaque,
                      child: const Material(color: Colors.transparent),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => childTapCalls++,
                    child: Container(
                      width: 200,
                      height: 40,
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: const Text('selectable content'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('selectable content'));
    await tester.pump(const Duration(milliseconds: 170));

    expect(childTapCalls, 1);
    expect(selectCalls, 0, reason: 'Stack hit-tests front children first; background overlay should not fire when child on top handles the tap');
  });

  testWidgets('double-tap on text in bubble does not trigger reply', (tester) async {
    var replyCalls = 0;
    var selectCalls = 0;

    // Models the fixed message.dart bubble structure:
    // Stack with back-layer MessageClickSurface + front-layer content (no onDoubleTap)
    // The back-layer handles blank-space taps; the front-layer content handles text natively.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () {},
                      child: MessageClickSurface(
                        behavior: HitTestBehavior.opaque,
                        onSelect: () => selectCalls++,
                        onDeselect: () {},
                        onReply: () => replyCalls++,
                        child: const Material(color: Colors.transparent),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      onLongPress: () {},
                      child: Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.all(8),
                        child: const SelectableText('hello world'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Double-tap on the text
    final textFinder = find.text('hello world');
    await tester.tap(textFinder);
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(textFinder);
    await tester.pumpAndSettle();

    expect(replyCalls, 0, reason: 'double-tap on text should select word, not trigger reply');
  });
}
