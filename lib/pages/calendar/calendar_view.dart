import 'package:cross_file/cross_file.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/services/backend_session_service.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:fluffychat/services/messie_workspace_refresh.dart';
import 'package:fluffychat/utils/adaptive_bottom_sheet.dart';
import 'package:fluffychat/utils/file_selector.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_ok_cancel_alert_dialog.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'calendar.dart';

class _CalendarPageData {
  const _CalendarPageData({required this.sources, required this.events});

  final List<MessieCalendarSource> sources;
  final List<MessieCalendarEvent> events;
}

enum _CalendarImportMode { link, file }

class _CalendarImportRequest {
  const _CalendarImportRequest.link({
    required this.url,
    required this.displayName,
  }) : mode = _CalendarImportMode.link,
       file = null;

  const _CalendarImportRequest.file({
    required this.file,
    required this.displayName,
  }) : mode = _CalendarImportMode.file,
       url = null;

  final _CalendarImportMode mode;
  final String? url;
  final XFile? file;
  final String displayName;
}

enum _CalendarInstructionPlatform { google, outlook, apple }

class _CalendarImportSheet extends StatefulWidget {
  const _CalendarImportSheet({
    required this.suggestDisplayName,
    required this.fallbackDisplayName,
  });

  final Future<String> Function(XFile file) suggestDisplayName;
  final String Function(String filename) fallbackDisplayName;

  @override
  State<_CalendarImportSheet> createState() => _CalendarImportSheetState();
}

class _CalendarImportSheetState extends State<_CalendarImportSheet> {
  _CalendarImportMode _mode = _CalendarImportMode.link;
  _CalendarInstructionPlatform _platform = _CalendarInstructionPlatform.google;
  bool _showInstructions = false;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  XFile? _selectedFile;
  bool _selectingFile = false;

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _selectingFile = true;
    });
    try {
      final files = await selectFiles(context, allowMultiple: false);
      if (!mounted || files.isEmpty) return;
      final file = files.first;
      if (!file.name.toLowerCase().endsWith('.ics')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose an .ics calendar file.')),
        );
        return;
      }
      final suggestedDisplayName = await widget.suggestDisplayName(file);
      if (!mounted) return;
      setState(() {
        final previousFallback = widget.fallbackDisplayName(
          _selectedFile?.name ?? '',
        );
        _selectedFile = file;
        if (_nameController.text.trim().isEmpty ||
            _nameController.text == previousFallback) {
          _nameController.text = suggestedDisplayName;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _selectingFile = false;
        });
      }
    }
  }

  void _submit() {
    if (_mode == _CalendarImportMode.link) {
      Navigator.of(context).pop(
        _CalendarImportRequest.link(
          url: _urlController.text,
          displayName: _nameController.text,
        ),
      );
      return;
    }

    final file = _selectedFile;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose an .ics file first.')),
      );
      return;
    }
    Navigator.of(context).pop(
      _CalendarImportRequest.file(
        file: file,
        displayName: _nameController.text,
      ),
    );
  }

  String get _primaryButtonLabel =>
      _mode == _CalendarImportMode.link ? 'Add calendar' : 'Import calendar';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import calendar',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start with an ICS link or upload a calendar file.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<_CalendarImportMode>(
                    selected: {_mode},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _mode = selection.first;
                      });
                    },
                    segments: const [
                      ButtonSegment(
                        value: _CalendarImportMode.link,
                        icon: Icon(Icons.link_outlined),
                        label: Text('From URL'),
                      ),
                      ButtonSegment(
                        value: _CalendarImportMode.file,
                        icon: Icon(Icons.upload_file_outlined),
                        label: Text('From file'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_mode == _CalendarImportMode.link) ...[
                    TextField(
                      controller: _urlController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'ICS URL',
                        hintText: 'https://calendar.example.com/feed.ics',
                        prefixIcon: Icon(Icons.link_outlined),
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFile?.name ?? 'No .ics file selected',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedFile == null
                                        ? 'Choose an exported calendar file from Google, Outlook, Apple, or another provider.'
                                        : 'Ready to import this calendar file.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.tonalIcon(
                              onPressed: _selectingFile ? null : _pickFile,
                              icon: _selectingFile
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.attach_file_outlined),
                              label: Text(
                                _selectedFile == null ? 'Choose file' : 'Replace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Calendar name',
                      hintText: _mode == _CalendarImportMode.link
                          ? 'Imported calendar'
                          : 'Name from the file',
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showInstructions = !_showInstructions;
                        });
                      },
                      icon: Icon(
                        _showInstructions
                            ? Icons.expand_less
                            : Icons.help_outline,
                      ),
                      label: Text(
                        _showInstructions
                            ? 'Hide setup instructions'
                            : 'Show setup instructions',
                      ),
                    ),
                  ),
                  if (_showInstructions) ...[
                    const SizedBox(height: 12),
                    _CalendarImportInstructions(
                      mode: _mode,
                      selectedPlatform: _platform,
                      onPlatformChanged: (platform) {
                        setState(() {
                          _platform = platform;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: Icon(
                    _mode == _CalendarImportMode.link
                        ? Icons.link_outlined
                        : Icons.upload_file_outlined,
                  ),
                  label: Text(_primaryButtonLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarImportInstructions extends StatelessWidget {
  const _CalendarImportInstructions({
    required this.mode,
    required this.selectedPlatform,
    required this.onPlatformChanged,
  });

  final _CalendarImportMode mode;
  final _CalendarInstructionPlatform selectedPlatform;
  final ValueChanged<_CalendarInstructionPlatform> onPlatformChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instructionLines = _instructionLines(selectedPlatform, mode);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mode == _CalendarImportMode.link
                  ? 'Find your ICS subscription link'
                  : 'Export an ICS calendar file',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              mode == _CalendarImportMode.link
                  ? 'Paste a read-only ICS subscription link from your calendar provider. For some providers, that link is private and should not be shared.'
                  : 'Upload a standard .ics export from your calendar provider. This is a one-time import, not a live sync.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<_CalendarInstructionPlatform>(
              selected: {selectedPlatform},
              onSelectionChanged: (selection) =>
                  onPlatformChanged(selection.first),
              segments: const [
                ButtonSegment(
                  value: _CalendarInstructionPlatform.google,
                  label: Text('Google'),
                ),
                ButtonSegment(
                  value: _CalendarInstructionPlatform.outlook,
                  label: Text('Outlook'),
                ),
                ButtonSegment(
                  value: _CalendarInstructionPlatform.apple,
                  label: Text('Apple'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...instructionLines.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${entry.key + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _instructionLines(
    _CalendarInstructionPlatform platform,
    _CalendarImportMode mode,
  ) {
    switch ((platform, mode)) {
      case (_CalendarInstructionPlatform.google, _CalendarImportMode.link):
        return const [
          'Open Google Calendar on a computer, go to Settings, then select the calendar under “Settings for my calendars.”',
          'Open Integrate calendar and copy the “Secret address in iCal format.”',
          'That link is private. Anyone with it can read the calendar, so do not share it publicly.',
          'Paste that ICS URL here. FluffyChat will sync it automatically every hour.',
        ];
      case (_CalendarInstructionPlatform.google, _CalendarImportMode.file):
        return const [
          'Open Google Calendar on a computer. To export one calendar, open that calendar’s “Settings and sharing” page and select “Export calendar.”',
          'To export everything, use Settings > Import & export > Export. Google downloads a ZIP file containing one .ics file per calendar.',
          'If you exported a ZIP, unzip it first, then upload the specific .ics file you want here.',
        ];
      case (_CalendarInstructionPlatform.outlook, _CalendarImportMode.link):
        return const [
          'Open Outlook Calendar on the web, then open Settings > Shared calendars or Calendar publishing.',
          'Under Publish a calendar, choose the calendar, choose the detail level, then publish it.',
          'Copy the ICS link, not the HTML link.',
          'The ICS link is read-only. Microsoft notes that update timing on the receiving side can vary.',
          'Paste that ICS URL here so FluffyChat can keep it synced.',
        ];
      case (_CalendarInstructionPlatform.outlook, _CalendarImportMode.file):
        return const [
          'If your Outlook version supports calendar export, export or save the calendar as an .ics file.',
          'If you only see publishing or subscription options in Outlook on the web, use the URL method instead. That is the more consistent path for Outlook.',
          'Upload the downloaded .ics file here.',
        ];
      case (_CalendarInstructionPlatform.apple, _CalendarImportMode.link):
        return const [
          'Open Calendar on iCloud.com and open the sharing options for the calendar you want.',
          'Turn on Public Calendar, then copy the shared calendar link.',
          'That public link is read-only but visible to anyone who has it.',
          'If the copied link starts with webcal://, replace it with https:// before pasting it here.',
          'Paste that ICS URL here so FluffyChat can keep it synced.',
        ];
      case (_CalendarInstructionPlatform.apple, _CalendarImportMode.file):
        return const [
          'On a Mac, open Calendar and use File > Export > Export to save the calendar as an .ics file.',
          'If you only have iCloud.com access, publicly share the calendar, copy the link into a browser, replace webcal with http, and download the ICS file.',
          'If you used public sharing only to download the file, turn public sharing back off afterward.',
          'Upload the .ics file here.',
        ];
    }
  }
}

class CalendarPageView extends StatefulWidget {
  const CalendarPageView(this.controller, {super.key});

  final CalendarPageController controller;

  @override
  State<CalendarPageView> createState() => _CalendarPageViewState();
}

class _CalendarPageViewState extends State<CalendarPageView> {
  final MessieCalendarService _calendarService = MessieCalendarService();
  late Future<_CalendarPageData> _loadFuture;
  late final ValueNotifier<DateTime> _visibleMonthNotifier;
  late final ValueNotifier<DateTime> _selectedDayNotifier;
  Set<String> _visibleSourceIds = <String>{};
  Set<String> _knownSourceIds = <String>{};
  bool _hasInitializedSourceSelection = false;

  CalendarPageController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonthNotifier = ValueNotifier<DateTime>(
      DateTime(now.year, now.month),
    );
    _selectedDayNotifier = ValueNotifier<DateTime>(
      DateTime(now.year, now.month, now.day),
    );
    _loadFuture = _load();
  }

  @override
  void dispose() {
    _visibleMonthNotifier.dispose();
    _selectedDayNotifier.dispose();
    super.dispose();
  }

  DateTime get _visibleMonth => _visibleMonthNotifier.value;

  DateTime get _selectedDay => _selectedDayNotifier.value;

  void _setVisibleMonth(DateTime month) {
    final normalized = DateTime(month.year, month.month);
    if (_isSameMonth(_visibleMonth, normalized)) return;
    _visibleMonthNotifier.value = normalized;
  }

  void _setSelectedDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    if (_isSameDay(_selectedDay, normalized)) return;
    _selectedDayNotifier.value = normalized;
  }

  void _selectDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    _setSelectedDay(normalizedDay);
    _setVisibleMonth(normalizedDay);
  }

  Future<_CalendarPageData> _load() async {
    final matrix = Matrix.of(context);
    final session = await BackendSessionService().ensureSession(
      matrix.client,
      matrix.store,
    );
    final now = DateTime.now().toUtc();
    final results = await Future.wait([
      _calendarService.getCalendarSources(
        apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
        jwt: session.token,
      ),
      _calendarService.getCalendarEvents(
        apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
        jwt: session.token,
        from: now.subtract(const Duration(days: 30)),
        to: now.add(const Duration(days: 180)),
      ),
    ]);
    final sources = results[0] as List<MessieCalendarSource>;
    final events = results[1] as List<MessieCalendarEvent>;
    return _CalendarPageData(sources: sources, events: events);
  }

  void _refreshPage() {
    setState(() {
      _loadFuture = _load();
    });
    controller.refresh();
  }

  Future<void> _openImportCalendarFlow(BuildContext context) async {
    final request = await showAdaptiveBottomSheet<_CalendarImportRequest>(
      context: context,
      builder: (context) => _CalendarImportSheet(
        suggestDisplayName: _suggestDisplayName,
        fallbackDisplayName: _fallbackDisplayName,
      ),
    );
    if (!context.mounted || request == null) return;

    final matrix = Matrix.of(context);
    final session = await BackendSessionService().ensureSession(
      matrix.client,
      matrix.store,
    );

    try {
      late final MessieCalendarImportResult result;
      if (request.mode == _CalendarImportMode.link) {
        result = await _calendarService.createLinkedCalendarSource(
          apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
          jwt: session.token,
          url: request.url!.trim(),
          displayName: request.displayName.trim().isEmpty
              ? null
              : request.displayName.trim(),
        );
      } else {
        result = await _calendarService.importCalendarSource(
          apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
          jwt: session.token,
          file: request.file!,
          displayName: request.displayName.trim().isEmpty
              ? null
              : request.displayName.trim(),
        );
      }
      if (!context.mounted) return;
      MessieWorkspaceRefresh.instance.bump();
      _refreshPage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            request.mode == _CalendarImportMode.link
                ? 'Added ${result.source.displayName} with ${result.importedEventCount} events.'
                : 'Imported ${result.importedEventCount} events from ${result.source.displayName}.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      await showOkAlertDialog(
        context: context,
        title: request.mode == _CalendarImportMode.link
            ? 'Could not add calendar link'
            : 'Could not import calendar',
        message: _formatErrorMessage(error),
        okLabel: 'Close',
      );
    }
  }

  Future<void> _renameSource(
    BuildContext context,
    MessieCalendarSource source,
  ) async {
    final displayName = await _promptForDisplayName(
      context,
      initialValue: source.displayName,
      title: 'Rename calendar',
      confirmLabel: 'Save',
    );
    if (!context.mounted || displayName == null) return;

    final trimmed = displayName.trim();
    if (trimmed.isEmpty || trimmed == source.displayName) return;

    final matrix = Matrix.of(context);
    final session = await BackendSessionService().ensureSession(
      matrix.client,
      matrix.store,
    );

    try {
      await _calendarService.updateCalendarSource(
        apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
        jwt: session.token,
        sourceId: source.id,
        displayName: trimmed,
      );
      if (!context.mounted) return;
      MessieWorkspaceRefresh.instance.bump();
      _refreshPage();
    } catch (error) {
      if (!context.mounted) return;
      await showOkAlertDialog(
        context: context,
        title: 'Could not rename calendar',
        message: _formatErrorMessage(error),
        okLabel: 'Close',
      );
    }
  }

  Future<void> _refreshSource(
    BuildContext context,
    MessieCalendarSource source,
  ) async {
    final matrix = Matrix.of(context);
    final session = await BackendSessionService().ensureSession(
      matrix.client,
      matrix.store,
    );

    try {
      final result = await _calendarService.refreshCalendarSource(
        apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
        jwt: session.token,
        sourceId: source.id,
      );
      if (!context.mounted) return;
      MessieWorkspaceRefresh.instance.bump();
      _refreshPage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Refreshed ${result.source.displayName}. ${result.importedEventCount} events imported.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      await showOkAlertDialog(
        context: context,
        title: 'Could not refresh calendar',
        message: _formatErrorMessage(error),
        okLabel: 'Close',
      );
    }
  }

  Future<String> _suggestDisplayName(XFile file) async {
    final fallback = _fallbackDisplayName(file.name);
    try {
      final contents = await file.readAsString();
      final unfolded = contents.replaceAll(RegExp(r'\r?\n[ \t]'), '');
      for (final propertyName in const ['NAME', 'X-WR-CALNAME']) {
        final match = RegExp(
          '^$propertyName(?:;[^:\\r\\n]+)*:(.+)\$',
          multiLine: true,
          caseSensitive: false,
        ).firstMatch(unfolded);
        if (match == null) continue;
        final value = match.group(1)?.trim() ?? '';
        if (value.isEmpty) continue;
        return _decodeICalText(value);
      }
    } catch (_) {
      // Fall back to the filename-derived name when the file contents are not
      // available as text in the current platform environment.
    }
    return fallback;
  }

  Future<String?> _promptForDisplayName(
    BuildContext context, {
    required String initialValue,
    String title = 'Import calendar',
    String confirmLabel = 'Import',
  }) async {
    final controller = TextEditingController(text: initialValue);
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Calendar name',
              hintText: 'Imported calendar',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => Navigator.of(dialogContext).pop(controller.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  String _fallbackDisplayName(String filename) {
    final trimmed = filename.trim();
    if (trimmed.isEmpty) return 'Imported calendar';
    if (trimmed.toLowerCase().endsWith('.ics')) {
      final name = trimmed.substring(0, trimmed.length - 4).trim();
      return name.isEmpty ? 'Imported calendar' : name;
    }
    return trimmed;
  }

  String _decodeICalText(String value) => value
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\N', '\n')
      .replaceAll(r'\,', ',')
      .replaceAll(r'\;', ';')
      .replaceAll(r'\\', '\\');

  Future<void> _deleteSource(
    BuildContext context,
    MessieCalendarSource source,
  ) async {
    final confirm = await showOkCancelAlertDialog(
      context: context,
      title: 'Delete calendar source?',
      message:
          'This removes ${source.displayName} and all imported events from FluffyChat.',
      okLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );
    if (confirm != OkCancelResult.ok || !context.mounted) return;

    final matrix = Matrix.of(context);
    final session = await BackendSessionService().ensureSession(
      matrix.client,
      matrix.store,
    );

    try {
      await _calendarService.deleteCalendarSource(
        apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
        jwt: session.token,
        sourceId: source.id,
      );
      if (!context.mounted) return;
      MessieWorkspaceRefresh.instance.bump();
      _refreshPage();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted ${source.displayName}.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  void _syncVisibleSources(List<MessieCalendarSource> sources) {
    final sourceIds = sources.map((source) => source.id).toSet();
    if (!_hasInitializedSourceSelection) {
      _visibleSourceIds = sourceIds;
      _knownSourceIds = sourceIds;
      _hasInitializedSourceSelection = true;
      return;
    }

    final newSourceIds = sourceIds.difference(_knownSourceIds);
    _visibleSourceIds = {
      ..._visibleSourceIds.where(sourceIds.contains),
      ...newSourceIds,
    };
    _knownSourceIds = sourceIds;
  }

  void _toggleSourceVisibility(String sourceId) {
    setState(() {
      if (_visibleSourceIds.contains(sourceId)) {
        _visibleSourceIds.remove(sourceId);
      } else {
        _visibleSourceIds.add(sourceId);
      }
    });
  }

  void _showAllSources(List<MessieCalendarSource> sources) {
    setState(() {
      _visibleSourceIds = sources.map((source) => source.id).toSet();
    });
  }

  void _hideAllSources() {
    setState(() {
      _visibleSourceIds.clear();
    });
  }

  Future<void> _showCreateEventPlaceholder(DateTime day) async {
    await showOkAlertDialog(
      context: context,
      title: 'Event creation coming next',
      message:
          'This day is selected and ready to prefill a new event: ${DateFormat.yMMMMEEEEd().format(day)}.',
      okLabel: 'Close',
    );
  }

  List<MessieCalendarEvent> _visibleEvents(
    List<MessieCalendarEvent> events,
  ) => events
      .where(
        (event) => _visibleSourceIds.contains(event.sourceId),
      )
      .toList()
    ..sort((left, right) {
      if (left.allDay != right.allDay) {
        return left.allDay ? -1 : 1;
      }
      return left.startsAt.compareTo(right.startsAt);
    });

  List<MessieCalendarEvent> _eventsForDay(
    Map<DateTime, List<MessieCalendarEvent>> eventsByDay,
    DateTime day,
  ) => eventsByDay[DateTime(day.year, day.month, day.day)] ?? const [];

  Map<DateTime, List<MessieCalendarEvent>> _buildEventsByDay(
    List<MessieCalendarEvent> events,
  ) {
    final grouped = <DateTime, List<MessieCalendarEvent>>{};
    for (final event in events) {
      final start = event.startsAt.toLocal();
      var end = event.endsAt.toLocal();
      if (!end.isAfter(start)) {
        end = start.add(const Duration(minutes: 1));
      }

      var cursor = DateTime(start.year, start.month, start.day);
      final lastDay = DateTime(end.year, end.month, end.day);
      while (!cursor.isAfter(lastDay)) {
        grouped.putIfAbsent(cursor, () => <MessieCalendarEvent>[]).add(event);
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    for (final eventsForDay in grouped.values) {
      eventsForDay.sort((left, right) {
        if (left.allDay != right.allDay) {
          return left.allDay ? -1 : 1;
        }
        return left.startsAt.compareTo(right.startsAt);
      });
    }
    return grouped;
  }

  List<List<DateTime>> _monthWeeks(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month);
    final start = firstOfMonth.subtract(Duration(days: firstOfMonth.weekday % 7));
    final lastOfMonth = DateTime(month.year, month.month + 1, 0);
    final trailingDays = 6 - (lastOfMonth.weekday % 7);
    final end = lastOfMonth.add(Duration(days: trailingDays));
    final weeks = <List<DateTime>>[];
    var cursor = start;
    while (!cursor.isAfter(end)) {
      weeks.add(
        List<DateTime>.generate(
          7,
          (index) => DateTime(
            cursor.year,
            cursor.month,
            cursor.day + index,
          ),
        ),
      );
      cursor = cursor.add(const Duration(days: 7));
    }
    return weeks;
  }

  Map<String, Color> _sourceColors(List<MessieCalendarSource> sources) {
    const palette = <Color>[
      Color(0xFF4F8CFF),
      Color(0xFF34A853),
      Color(0xFFF9AB00),
      Color(0xFFB468F2),
      Color(0xFFE65C5C),
      Color(0xFF00A7B3),
      Color(0xFF7C8BFF),
      Color(0xFF9E9D24),
    ];

    return {
      for (var index = 0; index < sources.length; index++)
        sources[index].id: palette[index % palette.length],
    };
  }

  Future<void> _handleSourceAction(
    BuildContext context,
    MessieCalendarSource source,
    String action,
  ) async {
    switch (action) {
      case 'rename':
        await _renameSource(context, source);
      case 'refresh':
        await _refreshSource(context, source);
      case 'delete':
        await _deleteSource(context, source);
    }
  }

  String _formatErrorMessage(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ')
        ? text.substring('Exception: '.length)
        : text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopLayout = MediaQuery.sizeOf(context).width >= 960;
    return Scaffold(
      appBar: isDesktopLayout
          ? null
          : AppBar(
              title: const Text('Calendar'),
              automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
              centerTitle: FluffyThemes.isColumnMode(context),
              actions: [
                IconButton(
                  tooltip: 'Import calendar',
                  onPressed: () => _openImportCalendarFlow(context),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
      body: FutureBuilder<_CalendarPageData>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return MaxWidthBody(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_busy_outlined, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load calendar data.',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _refreshPage,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final data = snapshot.requireData;
          _syncVisibleSources(data.sources);
          final visibleEvents = _visibleEvents(data.events);
          final eventsByDay = _buildEventsByDay(visibleEvents);
          final sourceColors = _sourceColors(data.sources);

          if (isDesktopLayout) {
            return _buildDesktopCalendar(
              context,
              theme,
              data,
              visibleEvents,
              eventsByDay,
              sourceColors,
            );
          }

          return _buildMobileCalendar(
            context,
            theme,
            data,
            visibleEvents,
            eventsByDay,
          );
        },
      ),
    );
  }

  Widget _buildDesktopCalendar(
    BuildContext context,
    ThemeData theme,
    _CalendarPageData data,
    List<MessieCalendarEvent> visibleEvents,
    Map<DateTime, List<MessieCalendarEvent>> eventsByDay,
    Map<String, Color> sourceColors,
  ) {
    return Column(
      children: [
        Material(
          color: theme.colorScheme.surface,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _openImportCalendarFlow(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Import'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      final today = DateTime.now();
                      _selectDay(today);
                    },
                    child: const Text('Today'),
                  ),
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: () => _setVisibleMonth(
                      DateTime(_visibleMonth.year, _visibleMonth.month - 1),
                    ),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    onPressed: () => _setVisibleMonth(
                      DateTime(_visibleMonth.year, _visibleMonth.month + 1),
                    ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                  const SizedBox(width: 12),
                  ValueListenableBuilder<DateTime>(
                    valueListenable: _visibleMonthNotifier,
                    builder: (context, visibleMonth, _) => Text(
                      DateFormat.yMMMM().format(visibleMonth),
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  const Spacer(),
                  SegmentedButton<String>(
                    selected: const {'month'},
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment<String>(
                        value: 'month',
                        icon: Icon(Icons.calendar_view_month_outlined),
                        label: Text('Month'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  border: Border(
                    right: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _visibleMonthNotifier,
                        _selectedDayNotifier,
                      ]),
                      builder: (context, _) => _buildMiniMonth(
                        context,
                        theme,
                        eventsByDay,
                        sourceColors,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Text(
                          'Imported calendars',
                          style: theme.textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: data.sources.isEmpty
                              ? null
                              : () => _showAllSources(data.sources),
                          child: const Text('Show all'),
                        ),
                        TextButton(
                          onPressed:
                              _visibleSourceIds.isEmpty ? null : _hideAllSources,
                          child: const Text('Hide all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (data.sources.isEmpty)
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No calendars imported yet',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Import an .ics file or calendar link to populate this view.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ...data.sources.map(
                      (source) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _visibleSourceIds.contains(source.id),
                                onChanged: (_) => _toggleSourceVisibility(source.id),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color:
                                      sourceColors[source.id] ??
                                      theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  source.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              if (source.importMode == 'link')
                                IconButton(
                                  tooltip: 'Refresh calendar',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _refreshSource(context, source),
                                  icon: const Icon(Icons.refresh_outlined),
                                ),
                              PopupMenuButton<String>(
                                tooltip: 'Calendar actions',
                                onSelected: (action) =>
                                    _handleSourceAction(context, source, action),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'rename',
                                    child: Text('Rename'),
                                  ),
                                  if (source.importMode == 'link')
                                    const PopupMenuItem(
                                      value: 'refresh',
                                      child: Text('Refresh'),
                                    ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<DateTime>(
                      valueListenable: _selectedDayNotifier,
                      builder: (context, _, _) => _buildSelectedDayCard(
                        context,
                        theme,
                        eventsByDay,
                        sourceColors,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _visibleMonthNotifier,
                      _selectedDayNotifier,
                    ]),
                    builder: (context, _) => _buildMonthGrid(
                      context,
                      theme,
                      visibleEvents,
                      eventsByDay,
                      sourceColors,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMonth(
    BuildContext context,
    ThemeData theme,
    Map<DateTime, List<MessieCalendarEvent>> eventsByDay,
    Map<String, Color> sourceColors,
  ) {
    final weeks = _monthWeeks(_visibleMonth);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  DateFormat.yMMMM().format(_visibleMonth),
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _setVisibleMonth(
                    DateTime(_visibleMonth.year, _visibleMonth.month - 1),
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _setVisibleMonth(
                    DateTime(_visibleMonth.year, _visibleMonth.month + 1),
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: weekdays
                  .map(
                    (label) => Expanded(
                      child: Center(child: Text(label, style: labelStyle)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            ...weeks.map(
              (week) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: week.map((day) {
                    final isCurrentMonth = day.month == _visibleMonth.month;
                    final isSelected = _isSameDay(day, _selectedDay);
                    final isToday = _isSameDay(day, DateTime.now());
                    final hasEvents = _eventsForDay(eventsByDay, day).isNotEmpty;
                    return Expanded(
                      child: Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => _selectDay(day),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : isToday
                                  ? theme.colorScheme.primaryContainer
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '${day.day}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : isCurrentMonth
                                        ? null
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (hasEvents)
                                  Positioned(
                                    bottom: 3,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: sourceColors.values.firstOrNull ??
                                            theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayCard(
    BuildContext context,
    ThemeData theme,
    Map<DateTime, List<MessieCalendarEvent>> eventsByDay,
    Map<String, Color> sourceColors,
  ) {
    final dayEvents = _eventsForDay(eventsByDay, _selectedDay);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMMEEEEd().format(_selectedDay),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _showCreateEventPlaceholder(_selectedDay),
              icon: const Icon(Icons.add),
              label: const Text('Create event'),
            ),
            const SizedBox(height: 12),
            if (dayEvents.isEmpty)
              Text(
                'No visible events on this day.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ...dayEvents.take(3).map(
              (event) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        sourceColors[event.sourceId] ?? theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  event.allDay ? 'All day' : _formatTime(context, event.startsAt),
                ),
                onTap: () => context.push(
                  '/rooms/calendar/events/${event.id}',
                  extra: <String, Object?>{
                    'title': event.title,
                    'sourceDisplayName': event.sourceDisplayName,
                  },
                ),
              ),
            ),
            if (dayEvents.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${dayEvents.length - 3} more',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid(
    BuildContext context,
    ThemeData theme,
    List<MessieCalendarEvent> visibleEvents,
    Map<DateTime, List<MessieCalendarEvent>> eventsByDay,
    Map<String, Color> sourceColors,
  ) {
    final weeks = _monthWeeks(_visibleMonth);
    const weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: weekdays
                .map(
                  (day) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day.substring(0, 3).toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Expanded(
            child: Column(
              children: weeks
                  .map(
                    (week) => Expanded(
                      child: Row(
                        children: week
                            .map(
                              (day) => Expanded(
                                child: _buildDayCell(
                                  context,
                                  theme,
                                  day,
                                  eventsByDay,
                                  sourceColors,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    ThemeData theme,
    DateTime day,
    Map<DateTime, List<MessieCalendarEvent>> eventsByDay,
    Map<String, Color> sourceColors,
  ) {
    final isCurrentMonth = day.month == _visibleMonth.month;
    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _isSameDay(day, _selectedDay);
    final dayEvents = _eventsForDay(eventsByDay, day);
    final visibleDayEvents = dayEvents.take(4).toList();
    final overflowCount = dayEvents.length - visibleDayEvents.length;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.22)
            : Colors.transparent,
        border: Border(
          right: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _selectDay(day),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isToday
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isToday
                            ? theme.colorScheme.onPrimary
                            : isCurrentMonth
                            ? null
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor,
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showCreateEventPlaceholder(day),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...visibleDayEvents.map(
                        (event) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _buildEventChip(
                            context,
                            theme,
                            day,
                            event,
                            sourceColors[event.sourceId] ??
                                theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      if (overflowCount > 0)
                        Text(
                          '+$overflowCount more',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventChip(
    BuildContext context,
    ThemeData theme,
    DateTime day,
    MessieCalendarEvent event,
    Color color,
  ) {
    final showContinuationPrefix =
        !_isSameDay(event.startsAt.toLocal(), day) && _eventSpansDay(event, day);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push(
        '/rooms/calendar/events/${event.id}',
        extra: <String, Object?>{
          'title': event.title,
          'sourceDisplayName': event.sourceDisplayName,
        },
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          [
            if (!event.allDay) _formatTime(context, event.startsAt),
            if (showContinuationPrefix) 'Continues',
            event.title,
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCalendar(
    BuildContext context,
    ThemeData theme,
    _CalendarPageData data,
    List<MessieCalendarEvent> visibleEvents,
    Map<DateTime, List<MessieCalendarEvent>> eventsByDay,
  ) {
    final groupedEvents = <DateTime, List<MessieCalendarEvent>>{};
    groupedEvents.addAll(eventsByDay);
    final groupedEntries = groupedEvents.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));

    return MaxWidthBody(
      withScrolling: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Imported calendars',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          if (data.sources.isEmpty)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('No calendars imported yet'),
                subtitle: const Text(
                  'Import an .ics file to bring your existing calendar events into FluffyChat.',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () => _openImportCalendarFlow(context),
                  child: const Text('Import'),
                ),
              ),
            ),
          ...data.sources.map(
            (source) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(source.displayName),
                subtitle: Text(
                  _formatSourceSubtitle(source),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) =>
                      _handleSourceAction(context, source, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Text('Rename'),
                    ),
                    if (source.importMode == 'link')
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Text('Refresh'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Events', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          if (groupedEntries.isEmpty)
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Icon(Icons.event_note_outlined),
                title: Text('No upcoming imported events'),
                subtitle: Text(
                  'Imported events will appear here and in the main workspace list.',
                ),
              ),
            ),
          for (final entry in groupedEntries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                _formatShortDate(entry.key),
                style: theme.textTheme.titleSmall,
              ),
            ),
            ...entry.value.map(
              (event) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () => context.push(
                    '/rooms/calendar/events/${event.id}',
                    extra: <String, Object?>{
                      'title': event.title,
                      'sourceDisplayName': event.sourceDisplayName,
                    },
                  ),
                  leading: const Icon(Icons.event_outlined),
                  title: Text(event.title),
                  subtitle: Text(
                    [
                      if (event.sourceDisplayName.isNotEmpty)
                        event.sourceDisplayName,
                      if (event.location.isNotEmpty) event.location,
                      if (event.description.isNotEmpty) event.description,
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    event.allDay ? 'All day' : _formatTime(context, event.startsAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isSameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;

  bool _isSameMonth(DateTime left, DateTime right) =>
      left.year == right.year && left.month == right.month;

  bool _eventSpansDay(MessieCalendarEvent event, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final start = event.startsAt.toLocal();
    var end = event.endsAt.toLocal();
    if (!end.isAfter(start)) {
      end = start.add(const Duration(minutes: 1));
    }
    return start.isBefore(dayEnd) && end.isAfter(dayStart);
  }

  String _formatShortDate(DateTime date) =>
      DateFormat.yMMMd().format(date.toLocal());

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${_formatShortDate(local)} ${_formatTimeFromLocal(local)}';
  }

  String _formatSourceSubtitle(MessieCalendarSource source) {
    final parts = <String>[
      source.importMode == 'link' ? 'linked' : 'uploaded',
    ];

    if (source.refreshState.isNotEmpty) {
      parts.add(source.refreshState);
    }
    if (source.lastSyncedAt != null) {
      parts.add('synced ${_formatDateTime(source.lastSyncedAt!)}');
    } else if (source.lastRefreshAttemptAt != null) {
      parts.add('checked ${_formatDateTime(source.lastRefreshAttemptAt!)}');
    }
    if (source.lastRefreshError != null && source.lastRefreshError!.isNotEmpty) {
      parts.add(source.lastRefreshError!);
    } else if (source.sourceUrl != null && source.sourceUrl!.isNotEmpty) {
      parts.add(_formatSourceUrl(source.sourceUrl!));
    }
    return parts.join(' · ');
  }

  String _formatSourceUrl(String sourceUrl) {
    final uri = Uri.tryParse(sourceUrl);
    if (uri == null || uri.host.isEmpty) {
      return sourceUrl;
    }

    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty);
    final pathSegments = segments.toList();
    if (pathSegments.isEmpty) {
      return uri.host;
    }
    if (pathSegments.length == 1) {
      return '${uri.host}/${pathSegments.first}';
    }

    return '${uri.host}/…/${pathSegments.last}';
  }

  String _formatTime(BuildContext context, DateTime dateTime) =>
      _formatTimeFromLocal(dateTime.toLocal());

  String _formatTimeFromLocal(DateTime local) {
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
