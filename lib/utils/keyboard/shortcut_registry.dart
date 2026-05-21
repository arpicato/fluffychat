import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum ShortcutCommand {
  search,
  escape,
  openFocusedChat,
  toggleFocusedMessageSelection,
  forwardFocusedMessage,
  replyFocusedMessage,
  editFocusedMessage,
  messageFocusUpModified,
  messageFocusDownModified,
  messagePageUp,
  messagePageDown,
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

enum ShortcutScope {
  global,
  chatList,
  chat,
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

class ShortcutDefinition {
  const ShortcutDefinition({
    required this.command,
    required this.scope,
    required this.label,
    required this.bindings,
  });

  final ShortcutCommand command;
  final ShortcutScope scope;
  final String label;
  final List<ShortcutBinding> bindings;
}

class AppShortcutRegistry {
  AppShortcutRegistry._();

  static final AppShortcutRegistry instance = AppShortcutRegistry._();

  static final bool isMac = defaultTargetPlatform == TargetPlatform.macOS;

  final List<ShortcutDefinition> definitions = [
    const ShortcutDefinition(
      command: ShortcutCommand.search,
      scope: ShortcutScope.global,
      label: 'Search',
      bindings: [
        ShortcutBinding(
          key: LogicalKeyboardKey.keyK,
          modifiers: {ShortcutModifier.primary},
        ),
      ],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.escape,
      scope: ShortcutScope.global,
      label: 'Escape / Back',
      bindings: [ShortcutBinding(key: LogicalKeyboardKey.escape)],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.openFocusedChat,
      scope: ShortcutScope.chatList,
      label: 'Open selected chat',
      bindings: [
        ShortcutBinding(key: LogicalKeyboardKey.enter),
        ShortcutBinding(
          key: LogicalKeyboardKey.enter,
          modifiers: {ShortcutModifier.alt},
        ),
      ],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.toggleFocusedMessageSelection,
      scope: ShortcutScope.chat,
      label: 'Toggle highlighted message selection',
      bindings: [ShortcutBinding(key: LogicalKeyboardKey.space)],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.forwardFocusedMessage,
      scope: ShortcutScope.chat,
      label: 'Forward highlighted message',
      bindings: [
        ShortcutBinding(
          key: LogicalKeyboardKey.keyF,
          modifiers: {ShortcutModifier.alt},
        ),
      ],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.replyFocusedMessage,
      scope: ShortcutScope.chat,
      label: 'Reply to highlighted message',
      bindings: [
        ShortcutBinding(
          key: LogicalKeyboardKey.keyR,
          modifiers: {ShortcutModifier.alt},
        ),
      ],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.editFocusedMessage,
      scope: ShortcutScope.chat,
      label: 'Edit highlighted message',
      bindings: [
        ShortcutBinding(
          key: LogicalKeyboardKey.keyE,
          modifiers: {ShortcutModifier.alt},
        ),
      ],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.messageFocusUpModified,
      scope: ShortcutScope.chat,
      label: 'Move message highlight up',
      bindings: [
        ShortcutBinding(
          key: LogicalKeyboardKey.arrowUp,
          modifiers: {ShortcutModifier.alt, ShortcutModifier.shift},
        ),
      ],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.messageFocusDownModified,
      scope: ShortcutScope.chat,
      label: 'Move message highlight down',
      bindings: [
        ShortcutBinding(
          key: LogicalKeyboardKey.arrowDown,
          modifiers: {ShortcutModifier.alt, ShortcutModifier.shift},
        ),
      ],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.chatListFocusUpModified,
      scope: ShortcutScope.chatList,
      label: 'Move chat highlight up',
      bindings: [
        ShortcutBinding(
          key: LogicalKeyboardKey.arrowUp,
          modifiers: {ShortcutModifier.alt},
        ),
      ],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.chatListFocusDownModified,
      scope: ShortcutScope.chatList,
      label: 'Move chat highlight down',
      bindings: [
        ShortcutBinding(
          key: LogicalKeyboardKey.arrowDown,
          modifiers: {ShortcutModifier.alt},
        ),
      ],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.messagePageUp,
      scope: ShortcutScope.chat,
      label: 'Page up through messages',
      bindings: [ShortcutBinding(key: LogicalKeyboardKey.pageUp)],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.messagePageDown,
      scope: ShortcutScope.chat,
      label: 'Page down through messages',
      bindings: [ShortcutBinding(key: LogicalKeyboardKey.pageDown)],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.arrowUp,
      scope: ShortcutScope.chat,
      label: 'Navigate up',
      bindings: [ShortcutBinding(key: LogicalKeyboardKey.arrowUp)],
    ),
    const ShortcutDefinition(
      command: ShortcutCommand.arrowDown,
      scope: ShortcutScope.chat,
      label: 'Navigate down',
      bindings: [ShortcutBinding(key: LogicalKeyboardKey.arrowDown)],
    ),
  ];

  late final Map<ShortcutCommand, ShortcutDefinition> _definitionsByCommand = {
    for (final definition in definitions) definition.command: definition,
  };

  List<ShortcutBinding> bindingsFor(ShortcutCommand command) =>
      _definitionsByCommand[command]?.bindings ?? const <ShortcutBinding>[];

  String labelFor(ShortcutCommand command) =>
      _definitionsByCommand[command]?.label ?? command.name;

  ShortcutScope scopeFor(ShortcutCommand command) =>
      _definitionsByCommand[command]?.scope ?? ShortcutScope.global;

  String formatBinding(ShortcutBinding binding) {
    final parts = <String>[];
    if (binding.modifiers.contains(ShortcutModifier.primary)) {
      parts.add(isMac ? 'Cmd' : 'Ctrl');
    }
    if (binding.modifiers.contains(ShortcutModifier.alt)) {
      parts.add(isMac ? 'Option' : 'Alt');
    }
    if (binding.modifiers.contains(ShortcutModifier.shift)) {
      parts.add('Shift');
    }
    parts.add(_formatKey(binding.key));
    return parts.join('+');
  }

  List<String> formattedBindingsFor(ShortcutCommand command) =>
      bindingsFor(command).map(formatBinding).toList();

  String _formatKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) return 'Up';
    if (key == LogicalKeyboardKey.arrowDown) return 'Down';
    if (key == LogicalKeyboardKey.arrowLeft) return 'Left';
    if (key == LogicalKeyboardKey.arrowRight) return 'Right';
    if (key == LogicalKeyboardKey.escape) return 'Esc';
    if (key == LogicalKeyboardKey.enter) return 'Enter';
    final label = key.keyLabel;
    if (label.isNotEmpty) return label.toUpperCase();
    return key.debugName ?? key.toString();
  }

  bool matches(
    ShortcutCommand command, {
    required LogicalKeyboardKey pressedKey,
    required bool primaryPressed,
    required bool altPressed,
    required bool shiftPressed,
  }) {
    final candidates = bindingsFor(command);
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
