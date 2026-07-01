// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/chat/private_sticker_picker_actions.dart';
import 'package:fluffychat/pages/chat/private_sticker_picker_app_bar_title.dart';
import 'package:fluffychat/pages/chat/private_sticker_picker_section.dart';
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
  String? _selectionPackId;
  final Set<String> _selectedPrivateEntryIds = <String>{};
  final Set<String> _deletingPackIds = <String>{};
  PrivateStickerLibraryLimits? _limits;

  bool _isSelectionModeForPack(String packId) => _selectionPackId == packId;

  void _startSelectionMode(String packId) {
    setState(() {
      _selectionPackId = packId;
      _selectedPrivateEntryIds.clear();
    });
  }

  void _clearSelectionMode() {
    setState(() {
      _selectionPackId = null;
      _selectedPrivateEntryIds.clear();
    });
  }

  void _togglePrivateEntrySelection(PrivateStickerLibraryEntry entry) {
    setState(() {
      if (_selectionPackId != entry.packId) {
        _selectionPackId = entry.packId;
        _selectedPrivateEntryIds.clear();
      }
      if (!_selectedPrivateEntryIds.add(entry.id)) {
        _selectedPrivateEntryIds.remove(entry.id);
      }
      if (_selectedPrivateEntryIds.isEmpty) {
        _selectionPackId = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    PrivateStickerLibraryService.instance.loadLimits(widget.room.client).then((limits) {
      if (mounted) setState(() => _limits = limits);
    }).catchError((_) {});
    if (PrivateStickerLibraryService.instance.packs(widget.room.client).isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await PrivateStickerLibraryService.instance.refresh(widget.room.client);
        if (mounted) setState(() {});
      });
    }
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
              (searchFilter?.isEmpty ?? true)
                  ? true
                  : (entry.body.toLowerCase().contains(searchFilter!.toLowerCase()) ||
                        entry.code.toLowerCase().contains(searchFilter!.toLowerCase())),
        )
        .toList();
    final privatePacks = {
      for (final pack in privateService.packs(widget.room.client)) pack.id: pack,
    };
    final privateEntriesByPack = <String, List<PrivateStickerLibraryEntry>>{
      for (final packId in privatePacks.keys)
        packId: privateEntries.where((entry) => entry.packId == packId).toList(),
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
              title: PrivateStickerPickerAppBarTitle(
                limits: _limits,
                onSearchChanged: (s) => setState(() => searchFilter = s),
                onCreatePressed: () => showCreateStickerMenu(
                  context: context,
                  client: widget.room.client,
                  onDone: () {
                    if (mounted) setState(() {});
                  },
                ),
              ),
              ),
              ...buildPrivateStickerPickerSlivers(
                context: context,
                client: widget.room.client,
                privateService: privateService,
                privatePacks: privatePacks,
                privateEntriesByPack: privateEntriesByPack,
                deletingPackIds: _deletingPackIds,
                selectionPackId: _selectionPackId,
                selectedPrivateEntryIds: _selectedPrivateEntryIds,
                onBulkMovePrivateStickers: (packId, packEntries) =>
                    bulkMovePrivateStickers(
                      context: context,
                      client: widget.room.client,
                      selectedPrivateEntryIds: _selectedPrivateEntryIds,
                      packEntries: packEntries,
                      onDone: () {
                        if (mounted) _clearSelectionMode();
                      },
                    ),
                onBulkDeletePrivateStickers: (packId, packEntries) =>
                    bulkDeletePrivateStickers(
                      context: context,
                      client: widget.room.client,
                      packId: packId,
                      selectedPrivateEntryIds: _selectedPrivateEntryIds,
                      packEntries: packEntries,
                      onDone: () {
                        if (mounted) _clearSelectionMode();
                      },
                    ),
                onStartSelectionMode: _startSelectionMode,
                onClearSelectionMode: _clearSelectionMode,
                onStateChange: setState,
                onDeletePrivatePack: (packId) => deletePrivatePack(
                  context: context,
                  client: widget.room.client,
                  packId: packId,
                  deletingPackIds: _deletingPackIds,
                  onStateChange: (fn) {
                    if (mounted) setState(fn);
                  },
                ),
                onShowPrivateStickerActions: (context, entry) =>
                    showPrivateStickerActions(
                      context: context,
                      client: widget.room.client,
                      entry: entry,
                      onDone: () {
                        if (mounted) setState(() {});
                      },
                    ),
                onTogglePrivateEntrySelection: _togglePrivateEntrySelection,
                onPrivateSelected: widget.onPrivateSelected,
              ),
               if (packSlugs.isNotEmpty) const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
