import 'package:fluffychat/pages/chat/message_focus_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FocusNode _wrapperFocusNode(WidgetTester tester, Finder wrapperFinder) {
  final focusFinder = find.descendant(
    of: wrapperFinder,
    matching: find.byType(Focus),
  );
  return tester.widget<Focus>(focusFinder.first).focusNode!;
}

void main() {
  testWidgets('MessageFocusWrapper calls onFocused when focused', (
    tester,
  ) async {
    var focusedCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: [
                MessageFocusWrapper(
                  order: 1,
                  onSelect: () {},
                  onFocused: () => focusedCalls++,
                  child: const SizedBox(width: 20, height: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final wrapperFocus = _wrapperFocusNode(
      tester,
      find.byType(MessageFocusWrapper),
    );
    wrapperFocus.requestFocus();
    await tester.pump();

    expect(focusedCalls, 1);
    expect(wrapperFocus.hasFocus, isTrue);
  });

  testWidgets('MessageFocusWrapper participates in ordered traversal', (
    tester,
  ) async {
    var firstWrapperFocused = 0;
    var secondWrapperFocused = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: [
                MessageFocusWrapper(
                  order: 1,
                  onSelect: () {},
                  onFocused: () => firstWrapperFocused++,
                  child: const SizedBox(width: 20, height: 20),
                ),
                MessageFocusWrapper(
                  order: 2,
                  onSelect: () {},
                  onFocused: () => secondWrapperFocused++,
                  child: const SizedBox(width: 20, height: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final wrappers = find.byType(MessageFocusWrapper);
    final firstFocus = _wrapperFocusNode(tester, wrappers.at(0));
    final secondFocus = _wrapperFocusNode(tester, wrappers.at(1));

    firstFocus.requestFocus();
    await tester.pump();
    expect(firstWrapperFocused, 1);
    expect(firstFocus.hasFocus, isTrue);

    final scope = FocusScope.of(tester.element(find.byType(Scaffold)));

    scope.nextFocus();
    await tester.pump();
    expect(secondWrapperFocused, 1);
    expect(secondFocus.hasFocus, isTrue);
  });
}
