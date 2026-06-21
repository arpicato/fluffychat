import 'package:fluffychat/pages/chat/chat.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Enter defers to composer suggestions when autocomplete is open', () {
    expect(
      shouldDeferEnterToComposerSuggestions(
        event: const KeyDownEvent(
          timeStamp: Duration.zero,
          physicalKey: PhysicalKeyboardKey.enter,
          logicalKey: LogicalKeyboardKey.enter,
        ),
        composerSuggestionsOpen: true,
      ),
      isTrue,
    );
  });

  test('Enter does not defer when autocomplete is closed', () {
    expect(
      shouldDeferEnterToComposerSuggestions(
        event: const KeyDownEvent(
          timeStamp: Duration.zero,
          physicalKey: PhysicalKeyboardKey.enter,
          logicalKey: LogicalKeyboardKey.enter,
        ),
        composerSuggestionsOpen: false,
      ),
      isFalse,
    );
  });

  test('Non-Enter keys do not defer even when autocomplete is open', () {
    expect(
      shouldDeferEnterToComposerSuggestions(
        event: const KeyDownEvent(
          timeStamp: Duration.zero,
          physicalKey: PhysicalKeyboardKey.arrowDown,
          logicalKey: LogicalKeyboardKey.arrowDown,
        ),
        composerSuggestionsOpen: true,
      ),
      isFalse,
    );
  });
}
