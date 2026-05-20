import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum ShortcutCommand {
  search,
  escape,
  openFocusedChat,
  replyFocusedMessage,
  editFocusedMessage,
  messageFocusUpModified,
  messageFocusDownModified,
  chatListFocusUpModified,
  chatListFocusDownModified,
  arrowUp,
  arrowDown,
}

enum ShortcutModifier {
  primary,
  alt,
  shift,
}

class ShortcutBinding {
  const ShortcutBinding({required this.key, this.modifiers = const {}});

  final LogicalKeyboardKey key;
  final Set<ShortcutModifier> modifiers;

  bool matches({
    required LogicalKeyboardKey pressedKey,
    required bool primaryPressed,
    required bool altPressed,
    required bool shiftPressed,
  }) {
    return pressedKey == key &&
        primaryPressed == modifiers.contains(ShortcutModifier.primary) &&
        altPressed == modifiers.contains(ShortcutModifier.alt) &&
        shiftPressed == modifiers.contains(ShortcutModifier.shift);
  }
}

class AppShortcutRegistry {
  AppShortcutRegistry._();

  static final AppShortcutRegistry instance = AppShortcutRegistry._();

  static final bool isMac = defaultTargetPlatform == TargetPlatform.macOS;

  final Map<ShortcutCommand, List<ShortcutBinding>> bindings = {
    ShortcutCommand.search: [
      const ShortcutBinding(
        key: LogicalKeyboardKey.keyK,
        modifiers: {ShortcutModifier.primary},
      ),
    ],
    ShortcutCommand.escape: [
      const ShortcutBinding(key: LogicalKeyboardKey.escape),
    ],
    ShortcutCommand.openFocusedChat: [
      const ShortcutBinding(key: LogicalKeyboardKey.enter),
      const ShortcutBinding(
        key: LogicalKeyboardKey.enter,
        modifiers: {ShortcutModifier.alt},
      ),
    ],
    ShortcutCommand.replyFocusedMessage: [
      const ShortcutBinding(
        key: LogicalKeyboardKey.keyR,
        modifiers: {ShortcutModifier.alt},
      ),
    ],
    ShortcutCommand.editFocusedMessage: [
      const ShortcutBinding(
        key: LogicalKeyboardKey.keyE,
        modifiers: {ShortcutModifier.alt},
      ),
    ],
    ShortcutCommand.messageFocusUpModified: [
      const ShortcutBinding(
        key: LogicalKeyboardKey.arrowUp,
        modifiers: {ShortcutModifier.alt, ShortcutModifier.shift},
      ),
    ],
    ShortcutCommand.messageFocusDownModified: [
      const ShortcutBinding(
        key: LogicalKeyboardKey.arrowDown,
        modifiers: {ShortcutModifier.alt, ShortcutModifier.shift},
      ),
    ],
    ShortcutCommand.chatListFocusUpModified: [
      const ShortcutBinding(
        key: LogicalKeyboardKey.arrowUp,
        modifiers: {ShortcutModifier.alt},
      ),
    ],
    ShortcutCommand.chatListFocusDownModified: [
      const ShortcutBinding(
        key: LogicalKeyboardKey.arrowDown,
        modifiers: {ShortcutModifier.alt},
      ),
    ],
    ShortcutCommand.arrowUp: [
      const ShortcutBinding(key: LogicalKeyboardKey.arrowUp),
    ],
    ShortcutCommand.arrowDown: [
      const ShortcutBinding(key: LogicalKeyboardKey.arrowDown),
    ],
  };

  bool matches(
    ShortcutCommand command, {
    required LogicalKeyboardKey pressedKey,
    required bool primaryPressed,
    required bool altPressed,
    required bool shiftPressed,
  }) {
    final candidates = bindings[command] ?? const <ShortcutBinding>[];
    return candidates.any(
      (binding) => binding.matches(
        pressedKey: pressedKey,
        primaryPressed: primaryPressed,
        altPressed: altPressed,
        shiftPressed: shiftPressed,
      ),
    );
  }
}
