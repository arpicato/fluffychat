// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:file_picker/file_picker.dart';
import 'package:fluffychat/services/messie_error_service.dart';
import 'package:fluffychat/services/private_sticker_library_service.dart';
import 'package:fluffychat/utils/file_selector.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_text_input_dialog.dart';
import 'package:fluffychat/widgets/future_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/matrix_api_lite/utils/logs.dart';

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

Future<PrivateStickerPack?> createPrivateStickerPack(
  BuildContext context,
  Client client,
) async {
  final service = PrivateStickerLibraryService.instance;
  final newPackName = await showTextInputDialog(
    context: context,
    title: 'New sticker pack',
    okLabel: 'Create',
  );
  final trimmed = newPackName?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  try {
    return await service.createPack(client: client, name: trimmed);
  } catch (error) {
    if (!context.mounted) return null;
    final message = error is MessieUserException
        ? error.userMessage
        : error.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    return null;
  }
}

Future<void> importImagesToPrivateStickerPack(
  BuildContext context,
  Client client, {
  required String packId,
}) async {
  final files = await selectFiles(
    context,
    type: FileType.image,
    allowMultiple: true,
  );
  if (files.isEmpty || !context.mounted) return;
  final result = await showFutureLoadingDialog<void>(
    context: context,
      futureWithProgress: (setProgress) async {
        for (final (index, file) in files.indexed) {
          setProgress(index / files.length);
          final started = DateTime.now();
          final bytes = await file.readAsBytes();
          await PrivateStickerLibraryService.instance.saveFileAsSticker(
            client: client,
            file: MatrixImageFile(
              bytes: bytes,
              name: file.name,
            ),
            name: file.name.split('.').first,
            packId: packId,
          );
          final elapsedMs = DateTime.now().difference(started).inMilliseconds;
          final message =
              'Sticker import single image ${index + 1}/${files.length}: total ${elapsedMs}ms, bytes ${bytes.length}';
          Logs().i(message);
          print(message);
          await Future<void>.delayed(Duration.zero);
      }
      setProgress(1);
    },
  );
  if (result.isError && context.mounted) {
    final error = result.asError!.error;
    final message = error is MessieUserException
        ? error.userMessage
        : error.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
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
              PrivateStickerPack newPack;
              try {
                newPack = await service.createPack(
                  client: event.room.client,
                  name: trimmed,
                );
              } catch (error) {
                if (!dialogContext.mounted) return;
                final message = error is MessieUserException
                    ? error.userMessage
                    : error.toString().replaceFirst('Exception: ', '');
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(message)),
                );
                return;
              }
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
