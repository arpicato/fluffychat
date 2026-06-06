import 'package:fluffychat/pages/chat_list/chat_list_context_menu_region.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('context menu region opens on long press', (tester) async {
    var opens = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatListContextMenuRegion(
            onShowContextMenu: (_) {
              opens += 1;
            },
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      ),
    );

    await tester.longPress(find.byType(ChatListContextMenuRegion));
    await tester.pump();

    expect(opens, 1);
  });

  testWidgets('context menu region opens on secondary tap', (tester) async {
    var opens = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatListContextMenuRegion(
            onShowContextMenu: (_) {
              opens += 1;
            },
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byType(ChatListContextMenuRegion),
      buttons: kSecondaryButton,
    );
    await tester.pump();

    expect(opens, 1);
  });
}
