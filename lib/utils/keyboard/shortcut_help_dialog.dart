import 'package:fluffychat/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'shortcut_help_model.dart';

Future<void> showShortcutHelpDialog(BuildContext context) {
  final sections = ShortcutHelpModel().buildSections();

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text('${L10n.of(context).help}: Keyboard shortcuts'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final section in sections) ...[
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                for (final entry in section.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(entry.label)),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            entry.bindings.join(' or '),
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    ),
  );
}
