// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:archive/archive.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/settings_emotes/emote_pack_archive.dart';
import 'package:fluffychat/pages/settings_emotes/settings_emotes.dart';
import 'package:fluffychat/services/private_sticker_library_service.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_ok_cancel_alert_dialog.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix/matrix.dart';

class ImportEmoteArchiveDialog extends StatefulWidget {
  final EmotesSettingsController controller;
  final Archive archive;

  const ImportEmoteArchiveDialog({
    super.key,
    required this.controller,
    required this.archive,
  });

  @override
  State<ImportEmoteArchiveDialog> createState() =>
      _ImportEmoteArchiveDialogState();
}

class _ImportEmoteArchiveDialogState extends State<ImportEmoteArchiveDialog> {
  Map<ArchiveFile, String> _importMap = {};

  bool _loading = false;

  double _progress = 0;

  @override
  void initState() {
    _importFileMap();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(L10n.of(context).importEmojis),
      content: _loading
          ? Center(child: CircularProgressIndicator(value: _progress))
          : SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                spacing: 8,
                children: _importMap.entries
                    .map(
                      (e) => _EmojiImportPreview(
                        key: ValueKey(e.key.name),
                        entry: e,
                        onNameChanged: (name) => _importMap[e.key] = name,
                        onRemove: () =>
                            setState(() => _importMap.remove(e.key)),
                      ),
                    )
                    .toList(),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _loading ? null : Navigator.of(context).pop,
          child: Text(L10n.of(context).cancel),
        ),
        TextButton(
          onPressed: _loading
              ? null
              : _importMap.isNotEmpty
              ? _addEmotePack
              : null,
          child: Text(L10n.of(context).importNow),
        ),
      ],
    );
  }

  void _importFileMap() {
    _importMap = buildEmoteImportMap(widget.archive);
  }

  Future<void> _addEmotePack() async {
    final matrix = Matrix.of(context);
    final service = PrivateStickerLibraryService.instance;
    setState(() {
      _loading = true;
      _progress = 0;
    });
    final imports = _importMap;
    final successfulImports = <String>{};

    await service.refresh(matrix.client);
    final existingCodes = service.entries(matrix.client).map((entry) => entry.code).toSet();

    // check for duplicates first

    final skipKeys = [];

    for (final entry in imports.entries) {
      final imageCode = entry.value;

      if (existingCodes.contains(imageCode)) {
        final completer = Completer<OkCancelResult>();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          final result = await showOkCancelAlertDialog(
            useRootNavigator: false,
            context: context,
            title: L10n.of(context).emoteExists,
            message: imageCode,
            cancelLabel: L10n.of(context).replace,
            okLabel: L10n.of(context).skip,
          );
          completer.complete(result);
        });

        final result = await completer.future;
        if (result == OkCancelResult.ok) {
          skipKeys.add(entry.key);
        }
      }
    }

    for (final key in skipKeys) {
      imports.remove(key);
    }

    for (final entry in imports.entries) {
      setState(() {
        _progress += 1 / imports.length;
      });
      final file = entry.key;
      final imageCode = entry.value;

      try {
        await service.saveFileAsSticker(
          client: matrix.client,
          file: MatrixImageFile(bytes: file.content, name: file.name),
          name: imageCode,
        );
        successfulImports.add(file.name);
        existingCodes.add(imageCode);
      } catch (e) {
        Logs().d('Could not upload emote $imageCode');
      }
    }

    if (!mounted) return;
    _importMap.removeWhere(
      (key, value) => successfulImports.contains(key.name),
    );

    _loading = false;
    _progress = 0;

    // in case we have unhandled / duplicated emotes left, don't pop
    if (mounted) setState(() {});
    if (_importMap.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.of(context).pop(),
      );
    }
  }
}

class _EmojiImportPreview extends StatefulWidget {
  final MapEntry<ArchiveFile, String> entry;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onRemove;

  const _EmojiImportPreview({
    super.key,
    required this.entry,
    required this.onNameChanged,
    required this.onRemove,
  });

  @override
  State<_EmojiImportPreview> createState() => _EmojiImportPreviewState();
}

class _EmojiImportPreviewState extends State<_EmojiImportPreview> {
  final hasErrorNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: support Lottie here as well ...
    final controller = TextEditingController(text: widget.entry.value);

    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          onPressed: widget.onRemove,
          icon: const Icon(Icons.remove_circle),
          tooltip: L10n.of(context).remove,
        ),
        ValueListenableBuilder(
          valueListenable: hasErrorNotifier,
          builder: (context, hasError, child) {
            if (hasError) return _ImageFileError(name: widget.entry.key.name);

            return Column(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                Image.memory(
                  widget.entry.key.content,
                  height: 64,
                  width: 64,
                  errorBuilder: (context, e, s) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _setRenderError(),
                    );

                    return _ImageFileError(name: widget.entry.key.name);
                  },
                ),
                SizedBox(
                  width: 128,
                  child: TextField(
                    controller: controller,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[-\w]+$')),
                    ],
                    autocorrect: false,
                    minLines: 1,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: L10n.of(context).emoteShortcode,
                      prefixText: ': ',
                      suffixText: ':',
                      border: const OutlineInputBorder(),
                      prefixStyle: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                      suffixStyle: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onChanged: widget.onNameChanged,
                    onSubmitted: widget.onNameChanged,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _setRenderError() {
    hasErrorNotifier.value = true;
    widget.onRemove.call();
  }
}

class _ImageFileError extends StatelessWidget {
  final String name;

  const _ImageFileError({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox.square(
      dimension: 64,
      child: Tooltip(
        message: name,
        child: Column(
          mainAxisAlignment: .start,
          mainAxisSize: .min,
          crossAxisAlignment: .center,
          children: [
            const Icon(Icons.error),
            Text(
              L10n.of(context).notAnImage,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
