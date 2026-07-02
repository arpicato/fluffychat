// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:fluffychat/services/private_sticker_library_service.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

List<Widget> buildPrivateStickerPickerSlivers({
  required BuildContext context,
  required Client client,
  required PrivateStickerLibraryService privateService,
  required Map<String, PrivateStickerPack> privatePacks,
  required Map<String, List<PrivateStickerLibraryEntry>> privateEntriesByPack,
  required Set<String> deletingPackIds,
  required String? selectionPackId,
  required Set<String> selectedPrivateEntryIds,
  required Future<void> Function(String packId, List<PrivateStickerLibraryEntry> packEntries)
  onBulkMovePrivateStickers,
  required Future<void> Function(String packId, List<PrivateStickerLibraryEntry> packEntries)
  onBulkDeletePrivateStickers,
  required void Function(String packId) onStartSelectionMode,
  required void Function(PrivateStickerLibraryEntry entry) onStartSelectionModeForEntry,
  required void Function() onClearSelectionMode,
  required void Function(VoidCallback fn) onStateChange,
  required Future<void> Function(String packId) onDeletePrivatePack,
  required Future<void> Function(BuildContext context, PrivateStickerLibraryEntry entry)
  onShowPrivateStickerActions,
  required void Function(PrivateStickerLibraryEntry entry) onTogglePrivateEntrySelection,
  required void Function(PrivateStickerLibraryEntry entry)? onPrivateSelected,
}) {
  return [
    if (privatePacks.isNotEmpty) ...[
      for (final packEntry in privatePacks.entries) ...[
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) {
              final packEntries = privateEntriesByPack[packEntry.key] ??
                  const <PrivateStickerLibraryEntry>[];
              final isDeletingPack = deletingPackIds.contains(packEntry.key);
              final isSelectionMode = selectionPackId == packEntry.key;
              final selectedCount = packEntries
                  .where((entry) => selectedPrivateEntryIds.contains(entry.id))
                  .length;
              return ListTile(
                leading: const Icon(Icons.lock_outlined),
                title: Text(
                  isSelectionMode ? '$selectedCount selected' : packEntry.value.name,
                ),
                trailing: isDeletingPack
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                      )
                    : isSelectionMode
                    ? Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Select all',
                            onPressed: () {
                              onStateChange(() {
                                selectedPrivateEntryIds
                                  ..clear()
                                  ..addAll(packEntries.map((entry) => entry.id));
                              });
                            },
                            icon: const Icon(Icons.select_all_outlined),
                          ),
                          IconButton(
                            tooltip: 'Move selected',
                            onPressed: selectedCount == 0
                                ? null
                                : () => onBulkMovePrivateStickers(
                                    packEntry.key,
                                    packEntries,
                                  ),
                            icon: const Icon(Icons.drive_file_move_outline),
                          ),
                          IconButton(
                            tooltip: 'Delete selected',
                            onPressed: selectedCount == 0
                                ? null
                                : () => onBulkDeletePrivateStickers(
                                    packEntry.key,
                                    packEntries,
                                  ),
                            icon: const Icon(Icons.delete_outline),
                          ),
                          IconButton(
                            tooltip: 'Cancel selection',
                            onPressed: onClearSelectionMode,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      )
                    : PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'select') {
                            onStartSelectionMode(packEntry.key);
                            return;
                          }
                          if (value == 'delete-pack') {
                            onDeletePrivatePack(packEntry.key);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'select',
                            child: Text('Manage stickers'),
                          ),
                          if (packEntry.value.name !=
                              privateStickerLibraryDefaultPackName)
                            const PopupMenuItem<String>(
                              value: 'delete-pack',
                              child: Text('Delete pack'),
                            ),
                        ],
                      ),
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverGrid.builder(
            itemCount:
                (privateEntriesByPack[packEntry.key] ?? const <PrivateStickerLibraryEntry>[])
                    .length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 84,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemBuilder: (context, index) {
              final packEntries = privateEntriesByPack[packEntry.key] ??
                  const <PrivateStickerLibraryEntry>[];
              final entry = packEntries[index];
              return FutureBuilder<Uint8List?>(
                future: privateService.loadPreviewBytes(client, entry),
                builder: (context, snapshot) => Tooltip(
                  message: entry.body,
                  child: InkWell(
                    onTap: selectionPackId == entry.packId
                        ? () => onTogglePrivateEntrySelection(entry)
                        : onPrivateSelected == null
                        ? null
                        : () => onPrivateSelected(entry),
                    onLongPress: () {
                      if (selectionPackId == entry.packId) {
                        onTogglePrivateEntrySelection(entry);
                        return;
                      }
                      onStartSelectionModeForEntry(entry);
                    },
                    child: snapshot.data == null
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(
                                snapshot.data!,
                                fit: BoxFit.contain,
                                gaplessPlayback: true,
                              ),
                              if (selectionPackId == entry.packId)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      selectedPrivateEntryIds.contains(entry.id)
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ],
  ];
}
