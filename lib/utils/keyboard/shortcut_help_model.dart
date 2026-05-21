import 'shortcut_registry.dart';

class ShortcutHelpSection {
  const ShortcutHelpSection({
    required this.scope,
    required this.title,
    required this.entries,
  });

  final ShortcutScope scope;
  final String title;
  final List<ShortcutHelpEntry> entries;
}

class ShortcutHelpEntry {
  const ShortcutHelpEntry({required this.label, required this.bindings});

  final String label;
  final List<String> bindings;
}

class ShortcutHelpModel {
  ShortcutHelpModel({AppShortcutRegistry? registry})
    : registry = registry ?? AppShortcutRegistry.instance;

  final AppShortcutRegistry registry;

  List<ShortcutHelpSection> buildSections() {
    final byScope = <ShortcutScope, List<ShortcutHelpEntry>>{};
    for (final definition in registry.definitions) {
      byScope.putIfAbsent(definition.scope, () => <ShortcutHelpEntry>[]).add(
        ShortcutHelpEntry(
          label: definition.label,
          bindings: definition.bindings.map(registry.formatBinding).toList(),
        ),
      );
    }

    return [
      for (final scope in ShortcutScope.values)
        if ((byScope[scope] ?? const <ShortcutHelpEntry>[]).isNotEmpty)
          ShortcutHelpSection(
            scope: scope,
            title: _titleForScope(scope),
            entries: byScope[scope]!,
          ),
    ];
  }

  String _titleForScope(ShortcutScope scope) {
    switch (scope) {
      case ShortcutScope.global:
        return 'Global';
      case ShortcutScope.chatList:
        return 'Chat list';
      case ShortcutScope.chat:
        return 'Chat';
    }
  }
}
