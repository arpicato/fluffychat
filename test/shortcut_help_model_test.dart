import 'package:fluffychat/utils/keyboard/shortcut_help_model.dart';
import 'package:fluffychat/utils/keyboard/shortcut_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShortcutHelpModel groups definitions by scope', () {
    final model = ShortcutHelpModel();

    final sections = model.buildSections();

    expect(sections.map((section) => section.scope), ShortcutScope.values);
    expect(
      sections.firstWhere((section) => section.scope == ShortcutScope.global)
          .entries
          .any((entry) => entry.label == 'Search'),
      isTrue,
    );
    expect(
      sections.firstWhere((section) => section.scope == ShortcutScope.chat)
          .entries
          .any((entry) => entry.bindings.contains('Alt+R')),
      isTrue,
    );
  });
}
