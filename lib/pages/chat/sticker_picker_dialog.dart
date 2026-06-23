// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/services/private_sticker_library_service.dart';
import 'package:fluffychat/utils/url_launcher.dart';
import 'package:fluffychat/widgets/mxc_image.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../../widgets/avatar.dart';

class StickerPickerDialog extends StatefulWidget {
  final Room room;
  final void Function(ImagePackImageContent) onSelected;
  final void Function(PrivateStickerLibraryEntry)? onPrivateSelected;

  const StickerPickerDialog({
    required this.onSelected,
    required this.room,
    this.onPrivateSelected,
    super.key,
  });

  @override
  StickerPickerDialogState createState() => StickerPickerDialogState();
}

class StickerPickerDialogState extends State<StickerPickerDialog> {
  String? searchFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PrivateStickerLibraryService.instance.refresh(widget.room.client);
      if (mounted) setState(() {});
    });
  }

  Future<void> _showPrivateStickerActions(
    BuildContext context,
    PrivateStickerLibraryEntry entry,
  ) async {
    final service = PrivateStickerLibraryService.instance;
    final client = widget.room.client;
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
    if (!mounted || choice == null) return;

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
                onPressed: () {
                  Navigator.of(context).pop(pendingPackId);
                },
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
      if (mounted) setState(() {});
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
    await service.deleteEntry(
      client: client,
      entry: entry,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final stickerPacks = widget.room.getImagePacks(ImagePackUsage.sticker);
    final privateService = PrivateStickerLibraryService.instance;
    final privateEntries = privateService
        .entries(widget.room.client)
        .where(
          (entry) =>
              searchFilter?.isEmpty ?? true
                  ? true
                  : (entry.body.toLowerCase().contains(searchFilter!.toLowerCase()) ||
                        entry.code.toLowerCase().contains(searchFilter!.toLowerCase())),
        )
        .toList();
    final privatePacks = {
      for (final pack in privateService.packs(widget.room.client)) pack.id: pack,
    };
    final packSlugs = stickerPacks.keys.toList();

    // ignore: prefer_function_declarations_over_variables
    final packBuilder = (BuildContext context, int packIndex) {
      final pack = stickerPacks[packSlugs[packIndex]]!;
      final filteredImagePackImageEntried = pack.images.entries.toList();
      if (searchFilter?.isNotEmpty ?? false) {
        filteredImagePackImageEntried.removeWhere(
          (e) =>
              !(e.key.toLowerCase().contains(searchFilter!.toLowerCase()) ||
                  (e.value.body?.toLowerCase().contains(
                        searchFilter!.toLowerCase(),
                      ) ??
                      false)),
        );
      }
      final imageKeys = filteredImagePackImageEntried
          .map((e) => e.key)
          .toList();
      if (imageKeys.isEmpty) {
        return const SizedBox.shrink();
      }
      final packName = pack.pack.displayName ?? packSlugs[packIndex];
      return Column(
        children: <Widget>[
            if (packIndex != 0) const SizedBox(height: 20),
          if (packName != 'user')
            ListTile(
              leading: Avatar(
                mxContent: pack.pack.avatarUrl,
                name: packName,
                client: widget.room.client,
              ),
              title: Text(packName),
            ),
          const SizedBox(height: 6),
          GridView.builder(
            itemCount: imageKeys.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 84,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int imageIndex) {
              final image = pack.images[imageKeys[imageIndex]]!;
              return Tooltip(
                message: image.body ?? imageKeys[imageIndex],
                child: InkWell(
                  radius: AppConfig.borderRadius,
                  key: ValueKey(image.url.toString()),
                  onTap: () {
                    // copy the image
                    final imageCopy = ImagePackImageContent.fromJson(
                      image.toJson().copy(),
                    );
                    // set the body, if it doesn't exist, to the key
                    imageCopy.body ??= imageKeys[imageIndex];
                    widget.onSelected(imageCopy);
                  },
                  child: AbsorbPointer(
                    absorbing: true,
                    child: MxcImage(
                      uri: image.url,
                      fit: BoxFit.contain,
                      width: 128,
                      height: 128,
                      animated: true,
                      isThumbnail: false,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    };

      return Scaffold(
      backgroundColor: theme.colorScheme.onInverseSurface,
      body: SizedBox(
        width: double.maxFinite,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              title: SizedBox(
                height: 42,
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: L10n.of(context).search,
                    prefixIcon: const Icon(Icons.search_outlined),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (s) => setState(() => searchFilter = s),
                ),
              ),
            ),
            if (privateEntries.isNotEmpty) ...[
              for (final packEntry in privatePacks.entries)
                if (privateEntries.any((entry) => entry.packId == packEntry.key)) ...[
                  SliverToBoxAdapter(
                    child: ListTile(
                      leading: const Icon(Icons.lock_outlined),
                      title: Text(packEntry.value.name),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    sliver: SliverGrid.builder(
                      itemCount: privateEntries
                          .where((entry) => entry.packId == packEntry.key)
                          .length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 84,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                          ),
                      itemBuilder: (context, index) {
                        final packEntries = privateEntries
                            .where((entry) => entry.packId == packEntry.key)
                            .toList();
                        final entry = packEntries[index];
                        return FutureBuilder<Uint8List?>(
                          future: privateService.loadPreviewBytes(
                            widget.room.client,
                            entry,
                          ),
                          builder: (context, snapshot) => Tooltip(
                            message: entry.body,
                            child: InkWell(
                              onTap: widget.onPrivateSelected == null
                                  ? null
                                  : () => widget.onPrivateSelected!(entry),
                               onLongPress: () => _showPrivateStickerActions(context, entry),
                              child: snapshot.data == null
                                  ? const Center(
                                      child: CircularProgressIndicator.adaptive(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.contain,
                                      gaplessPlayback: true,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              if (packSlugs.isNotEmpty) const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
            if (packSlugs.isEmpty && privateEntries.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Text(L10n.of(context).noEmotesFound),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => UrlLauncher(
                          context,
                          AppConfig.howDoIGetStickersTutorial,
                        ).launchUrl(),
                        icon: const Icon(Icons.explore_outlined),
                        label: Text(L10n.of(context).discover),
                      ),
                    ],
                  ),
                ),
              )
            else if (packSlugs.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  packBuilder,
                  childCount: packSlugs.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
