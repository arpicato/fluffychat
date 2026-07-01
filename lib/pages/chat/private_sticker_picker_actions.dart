// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:archive/archive.dart'
    if (dart.library.io) 'package:archive/archive_io.dart';
import 'package:fluffychat/pages/chat/import_private_sticker_archive_dialog.dart';
import 'package:fluffychat/services/private_sticker_library_actions.dart';
import 'package:fluffychat/services/private_sticker_library_service.dart';
import 'package:fluffychat/utils/file_selector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

Future<void> bulkMovePrivateStickers({
  required BuildContext context,
  required Client client,
  required Set<String> selectedPrivateEntryIds,
  required List<PrivateStickerLibraryEntry> packEntries,
  required VoidCallback onDone,
}) async {
  final service = PrivateStickerLibraryService.instance;
  final selectedEntries = packEntries
      .where((entry) => selectedPrivateEntryIds.contains(entry.id))
      .toList();
  if (selectedEntries.isEmpty) return;
  final packs = service
      .packs(client)
      .where((pack) => pack.id != packEntries.first.packId)
      .toList();
  if (packs.isEmpty) return;
  final controller = TextEditingController(text: packs.first.name);
  var pendingPackId = packs.first.id;
  final selectedPackId = await showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Move selected stickers'),
        content: DropdownMenu<String>(
          controller: controller,
          width: double.infinity,
          enableFilter: true,
          enableSearch: true,
          requestFocusOnTap: true,
          label: const Text('Sticker pack'),
          initialSelection: pendingPackId,
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
              pendingPackId = value;
              controller.text = packs.firstWhere((pack) => pack.id == value).name;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(pendingPackId),
            child: const Text('Move'),
          ),
        ],
      ),
    ),
  );
  if (selectedPackId == null) return;
  for (final entry in selectedEntries) {
    await service.moveEntryToPack(
      client: client,
      entry: entry,
      packId: selectedPackId,
    );
  }
  onDone();
}

Future<void> bulkDeletePrivateStickers({
  required BuildContext context,
  required Client client,
  required String packId,
  required Set<String> selectedPrivateEntryIds,
  required List<PrivateStickerLibraryEntry> packEntries,
  required VoidCallback onDone,
}) async {
  final service = PrivateStickerLibraryService.instance;
  final selectedEntries = packEntries
      .where((entry) => selectedPrivateEntryIds.contains(entry.id))
      .toList();
  if (selectedEntries.isEmpty) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete selected stickers?'),
      content: Text('${selectedEntries.length} stickers will be deleted.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await service.deleteEntries(
    client: client,
    packId: packId,
    entryIds: selectedEntries.map((entry) => entry.id).toList(),
  );
  onDone();
}

Future<void> deletePrivatePack({
  required BuildContext context,
  required Client client,
  required String packId,
  required Set<String> deletingPackIds,
  required void Function(VoidCallback fn) onStateChange,
}) async {
  final service = PrivateStickerLibraryService.instance;
  PrivateStickerPack? pack;
  for (final candidate in service.packs(client)) {
    if (candidate.id == packId) {
      pack = candidate;
      break;
    }
  }
  if (pack == null) return;
  final resolvedPack = pack;
  if (service.isPackImporting(packId)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wait for sticker import to finish before deleting this pack.'),
      ),
    );
    return;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete sticker pack?'),
      content: Text(resolvedPack!.name),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  onStateChange(() => deletingPackIds.add(packId));
  try {
    await service.deletePack(
      client: client,
      packId: packId,
      moveEntriesToDefault: false,
    );
    onStateChange(() {});
  } finally {
    onStateChange(() => deletingPackIds.remove(packId));
  }
}

Future<void> showCreateStickerMenu({
  required BuildContext context,
  required Client client,
  required VoidCallback onDone,
}) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add_photo_alternate_outlined),
            title: const Text('Create from image'),
            onTap: () => Navigator.of(context).pop('image'),
          ),
          ListTile(
            leading: const Icon(Icons.folder_zip_outlined),
            title: const Text('Import from .zip'),
            onTap: () => Navigator.of(context).pop('zip'),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || action == null) return;
  if (action == 'image') {
    final selectedPack = await selectTargetPack(context: context, client: client);
    if (selectedPack == null || !context.mounted) return;
    await importImagesToPrivateStickerPack(
      context,
      client,
      packId: selectedPack.id,
    );
    onDone();
    return;
  }

  final files = await selectFiles(context, type: FileType.any);
  if (files.isEmpty || !context.mounted) return;
  final selectedFile = files.single;
  final buffer = InputMemoryStream(await files.single.readAsBytes());
  final archive = ZipDecoder().decodeStream(buffer);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) => ImportPrivateStickerArchiveDialog(
      client: client,
      archive: archive,
      suggestedPackName: selectedFile.name.split('.').first,
    ),
  );
  onDone();
}

Future<PrivateStickerPack?> selectTargetPack({
  required BuildContext context,
  required Client client,
}) async {
  final service = PrivateStickerLibraryService.instance;
  var packs = service.packs(client);
  if (packs.isEmpty) return null;
  var selectedPackId = packs.first.id;
  final controller = TextEditingController(text: packs.first.name);

  void refreshPacks([PrivateStickerPack? selectedPack]) {
    packs = service.packs(client);
    final resolvedPack = selectedPack ?? packs.firstWhere(
      (pack) => pack.id == selectedPackId,
      orElse: () => packs.first,
    );
    selectedPackId = resolvedPack.id;
    controller.text = resolvedPack.name;
  }

  return showDialog<PrivateStickerPack>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Choose sticker pack'),
        content: DropdownMenu<String>(
          controller: controller,
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
              controller.text = packs.firstWhere((pack) => pack.id == value).name;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newPack = await createPrivateStickerPack(dialogContext, client);
              if (newPack == null) return;
              setState(() => refreshPacks(newPack));
            },
            child: const Text('New pack'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              packs.firstWhere((pack) => pack.id == selectedPackId),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showPrivateStickerActions({
  required BuildContext context,
  required Client client,
  required PrivateStickerLibraryEntry entry,
  required VoidCallback onDone,
}) async {
  final service = PrivateStickerLibraryService.instance;
  final packMap = {for (final pack in service.packs(client)) pack.id: pack};
  final currentPack = packMap[entry.packId];
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.drive_file_move_outline),
            title: const Text('Move to pack'),
            subtitle: currentPack == null ? null : Text(currentPack.name),
            onTap: () => Navigator.of(context).pop('move'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete saved sticker'),
            onTap: () => Navigator.of(context).pop('delete'),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || choice == null) return;

  if (choice == 'move') {
    final packs = service.packs(client);
    final controller = TextEditingController(text: currentPack?.name ?? '');
    var pendingPackId = entry.packId;
    final selectedPackId = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Move sticker to pack'),
          content: DropdownMenu<String>(
            controller: controller,
            width: double.infinity,
            enableFilter: true,
            enableSearch: true,
            requestFocusOnTap: true,
            label: const Text('Sticker pack'),
            initialSelection: entry.packId,
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
                pendingPackId = value;
                controller.text = packs.firstWhere((pack) => pack.id == value).name;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(pendingPackId),
              child: const Text('Move'),
            ),
          ],
        ),
      ),
    );
    if (selectedPackId == null || selectedPackId == entry.packId) return;
    await service.moveEntryToPack(
      client: client,
      entry: entry,
      packId: selectedPackId,
    );
    onDone();
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete saved sticker?'),
      content: Text(entry.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await service.deleteEntry(client: client, entry: entry);
  onDone();
}
