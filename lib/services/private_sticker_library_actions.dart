// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/services/private_sticker_library_service.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_text_input_dialog.dart';
import 'package:fluffychat/widgets/future_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

Future<void> saveEventToStickerLibrary(
  BuildContext context,
  Event event,
) async {
  final choice = await _showSaveToStickerLibraryDialog(context, event);
  if (choice == null || !context.mounted) return;
  await showFutureLoadingDialog<void>(
    context: context,
    future: () => PrivateStickerLibraryService.instance.saveEventAsSticker(
      client: event.room.client,
      event: event,
      name: choice.name,
      packId: choice.pack.id,
    ),
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Saved to sticker library')),
  );
}

Future<_SaveToStickerLibraryChoice?> _showSaveToStickerLibraryDialog(
  BuildContext context,
  Event event,
) async {
  final service = PrivateStickerLibraryService.instance;
  await service.refresh(event.room.client);
  final suggestedName = service.suggestedNameForEvent(event);
  var packs = service.packs(event.room.client);
  var selectedPackId = packs.first.id;
  final nameController = TextEditingController(text: suggestedName);
  final packController = TextEditingController(text: packs.first.name);

  void refreshPacks([PrivateStickerPack? selectedPack]) {
    packs = service.packs(event.room.client);
    final resolvedPack = selectedPack ?? packs.firstWhere(
      (pack) => pack.id == selectedPackId,
      orElse: () => packs.first,
    );
    selectedPackId = resolvedPack.id;
    packController.text = resolvedPack.name;
  }

  return showDialog<_SaveToStickerLibraryChoice>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Save to sticker library'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Sticker name'),
            ),
            const SizedBox(height: 12),
            DropdownMenu<String>(
              controller: packController,
              width: double.infinity,
              enableFilter: true,
              enableSearch: true,
              requestFocusOnTap: true,
              label: const Text('Sticker pack'),
              initialSelection: selectedPackId,
              dropdownMenuEntries: packs
                  .map(
                    (pack) => DropdownMenuEntry<String>(
                      value: pack.id,
                      label: pack.name,
                    ),
                  )
                  .toList(),
              onSelected: (value) {
                if (value == null) return;
                setState(() {
                  selectedPackId = value;
                  packController.text = packs
                      .firstWhere((pack) => pack.id == value)
                      .name;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newPackName = await showTextInputDialog(
                context: dialogContext,
                title: 'New sticker pack',
                okLabel: 'Create',
              );
              final trimmed = newPackName?.trim();
              if (trimmed == null || trimmed.isEmpty) return;
              final newPack = await service.createPack(
                client: event.room.client,
                name: trimmed,
              );
              setState(() => refreshPacks(newPack));
            },
            child: const Text('New pack'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = nameController.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.of(dialogContext).pop(
                _SaveToStickerLibraryChoice(
                  name: trimmed,
                  pack: packs.firstWhere((pack) => pack.id == selectedPackId),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

class _SaveToStickerLibraryChoice {
  _SaveToStickerLibraryChoice({required this.name, required this.pack});

  final String name;
  final PrivateStickerPack pack;
}
