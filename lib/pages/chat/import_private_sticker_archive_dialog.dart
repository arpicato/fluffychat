// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:math' as math;

import 'package:archive/archive.dart'
    if (dart.library.io) 'package:archive/archive_io.dart';
import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/pages/settings_emotes/emote_pack_archive.dart';
import 'package:fluffychat/services/messie_error_service.dart';
import 'package:fluffychat/services/private_sticker_library_actions.dart';
import 'package:fluffychat/services/private_sticker_library_service.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_ok_cancel_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix/matrix.dart';

String _displayImportError(Object error) {
  if (error is MessieUserException) return error.userMessage;
  return error.toString().replaceFirst('Exception: ', '');
}

class ImportPrivateStickerArchiveDialog extends StatefulWidget {
  const ImportPrivateStickerArchiveDialog({
    required this.client,
    required this.archive,
    required this.suggestedPackName,
    super.key,
  });

  final Client client;
  final Archive archive;
  final String suggestedPackName;

  @override
  State<ImportPrivateStickerArchiveDialog> createState() =>
      _ImportPrivateStickerArchiveDialogState();
}

class _ImportPrivateStickerArchiveDialogState
    extends State<ImportPrivateStickerArchiveDialog> {
  static const _maxConcurrentImports = 3;

  final service = PrivateStickerLibraryService.instance;
  final packController = TextEditingController();
  final newPackController = TextEditingController();
  Map<ArchiveFile, String> _importMap = {};
  final Map<ArchiveFile, String> _entryErrors = {};
  List<PrivateStickerPack> _packs = const [];
  String? _selectedPackId;
  bool _importIntoNewPack = true;
  bool _loading = false;
  double _progress = 0;
  String? _errorMessage;
  PrivateStickerLibraryLimits? _limits;

  Future<void> _refreshLimits() async {
    final limits = await service.loadLimits(widget.client);
    if (!mounted) return;
    setState(() => _limits = limits);
  }

  @override
  void initState() {
    super.initState();
    _importMap = buildEmoteImportMap(widget.archive);
    _packs = service.packs(widget.client);
    newPackController.text = widget.suggestedPackName;
    if (_packs.isNotEmpty) {
      _selectedPackId = _packs.first.id;
      packController.text = _packs.first.name;
    }
    _refreshLimits().catchError((_) {});
  }

  @override
  void dispose() {
    packController.dispose();
    newPackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(L10n.of(context).importEmojis),
      content: _loading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 12),
                Text(
                  '${(_progress * 100).round()}%',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Import continues in background if hidden.',
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              icon: Icon(Icons.create_new_folder_outlined),
                              label: Text('New pack'),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              icon: Icon(Icons.folder_open_outlined),
                              label: Text('Existing pack'),
                            ),
                          ],
                          selected: {_importIntoNewPack},
                          onSelectionChanged: (selection) {
                            setState(() {
                      _importIntoNewPack = selection.first;
                      _errorMessage = null;
                    });
                  },
                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_importIntoNewPack)
                    TextField(
                      controller: newPackController,
                      decoration: const InputDecoration(
                        labelText: 'New sticker pack',
                      ),
                    )
                  else
                    DropdownMenu<String>(
                      controller: packController,
                      width: double.infinity,
                      enableFilter: true,
                      enableSearch: true,
                      requestFocusOnTap: true,
                      label: const Text('Sticker pack'),
                      initialSelection: _selectedPackId,
                      dropdownMenuEntries: _packs
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
                          _selectedPackId = value;
                          packController.text = _packs
                              .firstWhere((pack) => pack.id == value)
                              .name;
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  if (_limits != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Saved stickers: ${_limits!.usedStickers}/${_limits!.maxStickers} • Zip: ${_importMap.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    if (_importMap.length > _limits!.remainingStickers)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Only ${_limits!.remainingStickers} more stickers can be saved. Extra stickers will fail.',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 8,
                    spacing: 8,
                    children: _importMap.entries
                        .map(
                          (e) => _PrivateStickerImportPreview(
                            key: ValueKey(e.key.name),
                            entry: e,
                            errorText: _entryErrors[e.key],
                            onNameChanged: (name) => _importMap[e.key] = name,
                            onRemove: () =>
                                setState(() {
                                  _importMap.remove(e.key);
                                  _entryErrors.remove(e.key);
                                }),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_loading ? 'Hide import' : L10n.of(context).cancel),
        ),
        TextButton(
          onPressed: _loading ||
                  _importMap.isEmpty ||
                  (!_importIntoNewPack && _selectedPackId == null) ||
                  (_importIntoNewPack && newPackController.text.trim().isEmpty) ||
                  ((_limits?.remainingStickers ?? 1) <= 0)
              ? null
              : _importIntoPrivatePack,
          child: const Text('Import'),
        ),
      ],
    );
  }

  Future<void> _importIntoPrivatePack() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final imports = _importMap;
    final successfulImports = <String>{};
    final existingCodes = service.entries(widget.client).map((entry) => entry.code).toSet();
    var targetPackId = _selectedPackId;
    setState(() {
      _errorMessage = null;
      _entryErrors.clear();
    });

    if (_importIntoNewPack) {
      PrivateStickerPack newPack;
      try {
        newPack = await service.createPack(
          client: widget.client,
          name: newPackController.text.trim(),
        );
      } catch (error) {
        if (mounted) {
          setState(() {
            _errorMessage = _displayImportError(error);
          });
        }
        return;
      }
      targetPackId = newPack.id;
      if (mounted) {
        setState(() {
          _packs = service.packs(widget.client);
          _selectedPackId = newPack.id;
          packController.text = newPack.name;
          _importIntoNewPack = false;
        });
      }
    }

    setState(() {
      _loading = true;
      _progress = 0;
    });

    final skipKeys = <ArchiveFile>[];
    for (final entry in imports.entries) {
      final imageCode = entry.value;
      if (!existingCodes.contains(imageCode)) continue;
      final result = await showOkCancelAlertDialog(
        useRootNavigator: false,
        context: context,
        title: L10n.of(context).emoteExists,
        message: imageCode,
        cancelLabel: L10n.of(context).replace,
        okLabel: L10n.of(context).skip,
      );
      if (result == OkCancelResult.ok) {
        skipKeys.add(entry.key);
      }
    }
    for (final key in skipKeys) {
      imports.remove(key);
    }

    final importEntries = importEntriesWithGate(imports.entries.toList());
    if (targetPackId == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _progress = 0;
          _errorMessage = 'No sticker pack selected.';
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _progress = importEntries.isEmpty ? 1 : 0;
      });
    }
    try {
      final resultMap = await service.bulkUploadFilesAsStickers(
        client: widget.client,
        packId: targetPackId,
        onProgress: (completed, total) {
          if (!mounted) return;
          setState(() {
            _progress = total == 0 ? 1 : completed / total;
          });
        },
        stickers: importEntries.indexed
            .map(
              (entry) => (
                requestId: entry.$1.toString(),
                file: MatrixImageFile(bytes: entry.$2.key.content, name: entry.$2.key.name),
                name: entry.$2.value,
              ),
            )
            .toList(),
      );
      for (final indexed in importEntries.indexed) {
        final error = resultMap[indexed.$1.toString()];
        if (error == null) {
          successfulImports.add(indexed.$2.key.name);
          existingCodes.add(indexed.$2.value);
          continue;
        }
        _entryErrors[indexed.$2.key] = error;
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _progress = 0;
          _errorMessage = _displayImportError(error);
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _progress = 1;
      });
    }

    final failedEntries = importEntries
        .where((entry) => !successfulImports.contains(entry.key.name))
        .toList();
    final failedCount = failedEntries.length;
    final importedCount = successfulImports.length;
    await _refreshLimits();

    if (mounted && failedCount == 0) {
      setState(() {
        _loading = false;
        _progress = 0;
        _errorMessage = null;
      });
      navigator.pop();
    } else if (mounted) {
      setState(() {
        _loading = false;
        _progress = 0;
        _importMap = Map.fromEntries(
          failedEntries.map((entry) => MapEntry(entry.key, entry.value)),
        );
        _errorMessage = importedCount == 0
            ? 'Import failed. Reasons shown below.'
            : 'Imported $importedCount. Fix failed stickers below and retry.';
      });
    }

    if (failedCount == 0) {
      messenger?.showSnackBar(
        SnackBar(content: Text('Imported $importedCount stickers.')),
      );
      return;
    }

    if (!mounted) {
      final failedNames = failedEntries.take(3).map((entry) => entry.value).join(', ');
      final moreSuffix = failedCount > 3 ? ' and ${failedCount - 3} more' : '';
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            importedCount == 0
                ? 'Import failed. Could not import $failedNames$moreSuffix.'
                : 'Imported $importedCount. Failed: $failedNames$moreSuffix.',
          ),
        ),
      );
    }
  }

  List<MapEntry<ArchiveFile, String>> importEntriesWithGate(
    List<MapEntry<ArchiveFile, String>> entries,
  ) {
    final limits = _limits;
    if (limits == null) return entries;
    final allowed = math.max(0, limits.remainingStickers);
    return entries.take(allowed).toList();
  }
}

class _PrivateStickerImportPreview extends StatefulWidget {
  const _PrivateStickerImportPreview({
    required this.entry,
    required this.errorText,
    required this.onNameChanged,
    required this.onRemove,
    super.key,
  });

  final MapEntry<ArchiveFile, String> entry;
  final String? errorText;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onRemove;

  @override
  State<_PrivateStickerImportPreview> createState() =>
      _PrivateStickerImportPreviewState();
}

class _PrivateStickerImportPreviewState
    extends State<_PrivateStickerImportPreview> {
  final hasErrorNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            if (hasError) return _ImportImageFileError(name: widget.entry.key.name ?? '');

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(
                  widget.entry.key.content,
                  height: 64,
                  width: 64,
                  errorBuilder: (context, e, s) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _setRenderError(),
                    );
                    return _ImportImageFileError(name: widget.entry.key.name ?? '');
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
                if (widget.errorText != null) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 128,
                    child: Text(
                      widget.errorText!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
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

class _ImportImageFileError extends StatelessWidget {
  const _ImportImageFileError({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.square(
      dimension: 64,
      child: Tooltip(
        message: name,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
