import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/services/messie_bridge_service.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_ok_cancel_alert_dialog.dart';
import 'package:fluffychat/widgets/adaptive_dialogs/show_text_input_dialog.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:messie_api/messie_api.dart' as api;
import 'package:pretty_qr_code/pretty_qr_code.dart';

class BridgeConnectionsPage extends StatefulWidget {
  const BridgeConnectionsPage({super.key});

  @override
  State<BridgeConnectionsPage> createState() => _BridgeConnectionsPageState();
}

class _BridgeConnectionsPageState extends State<BridgeConnectionsPage> {
  static const _provider = 'whatsapp';

  final MessieBridgeService _service = MessieBridgeService();
  late Future<MessieBridgeState> _bridgeStateFuture;

  Client get _client => Matrix.of(context).client;

  @override
  void initState() {
    super.initState();
    _bridgeStateFuture = _loadState();
  }

  Future<MessieBridgeState> _loadState() =>
      _service.loadState(_client, provider: _provider);

  Future<bool> _refreshAndCheckConnected() async {
    final state = await _loadState();
    if (mounted) {
      setState(() {
        _bridgeStateFuture = Future.value(state);
      });
    }
    final connected = state.connection?.status == api.BridgeConnectionStatusEnum.connected;
    return connected || state.logins.isNotEmpty;
  }

  Future<void> _refresh() async {
    final future = _loadState();
    if (mounted) {
      setState(() {
        _bridgeStateFuture = future;
      });
    }
    await future;
  }

  Future<void> _startFlow(api.BridgeLoginFlow flow) async {
    try {
      var step = await _service.startLogin(
        _client,
        provider: _provider,
        flow: flow.id,
      );
      while (mounted) {
        if (step.isComplete) {
          await _refresh();
          if (!mounted) return;
          _showSnackBar('WhatsApp connected.');
          return;
        }
        if (step.isDisplayAndWait) {
          if (!mounted) return;
          final result = await showDialog<_BridgeDisplayDialogResult>(
            context: context,
            builder: (context) => _BridgeDisplayAndWaitDialog(
              initialStep: step,
              selectedFlowId: flow.id,
              onPoll: () => _submitProvisioningStep(step, const {}),
              onMissingProcess: _refreshAndCheckConnected,
            ),
          );
          if (result == null || !mounted) return;
          if (result.restart) {
            step = await _service.startLogin(
              _client,
              provider: _provider,
              flow: flow.id,
            );
            continue;
          }
          final nextStep = result.step;
          if (nextStep == null) return;
          step = nextStep;
          continue;
        }
        if (step.isUserInput) {
          final input = await _collectUserInput(step);
          if (input == null || !mounted) return;
          step = await _submitProvisioningStep(step, input);
          continue;
        }
        if (step.isCookies) {
          if (!mounted) return;
          final rawJson = await showTextInputDialog(
            context: context,
            useRootNavigator: false,
            title: 'Paste cookies JSON',
            message:
                'This bridge flow expects a JSON object of cookie values from the remote service.',
            labelText: 'Cookies JSON',
            minLines: 6,
            maxLines: 10,
            validator: (input) {
              try {
                final decoded = jsonDecode(input);
                if (decoded is! Map) return 'Enter a JSON object.';
              } catch (_) {
                return 'Enter valid JSON.';
              }
              return null;
            },
          );
          if (rawJson == null || !mounted) return;
          final payload = (jsonDecode(rawJson) as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          );
          step = await _submitProvisioningStep(step, payload);
          continue;
        }
        throw Exception('Unsupported provisioning step: ${step.type}');
      }
    } catch (error) {
      if (!mounted) return;
      await _showErrorDialog('Could not start bridge login', error);
    }
  }

  Future<MessieBridgeProvisioningStep> _submitProvisioningStep(
    MessieBridgeProvisioningStep step,
    Map<String, Object?> body,
  ) {
    final processId = step.effectiveProcessId;
    final stepId = step.stepId;
    if (processId == null || stepId == null) {
      throw Exception('Bridge step is missing process metadata.');
    }
    return _service.submitStep(
      _client,
      provider: _provider,
      processId: processId,
      stepId: stepId,
      action: step.type,
      body: body,
    );
  }

  Future<Map<String, Object?>?> _collectUserInput(
    MessieBridgeProvisioningStep step,
  ) async {
    final values = <String, Object?>{};
    for (final field in step.fields) {
      final value = await showTextInputDialog(
        context: context,
        useRootNavigator: false,
        title: field.label ?? field.id,
        labelText: field.label ?? field.id,
        hintText: field.kind,
        obscureText: field.secret,
        validator: (input) =>
            input.trim().isEmpty ? 'This field is required.' : null,
      );
      if (value == null) return null;
      values[field.id] = value.trim();
    }
    return values;
  }

  Future<void> _logout(String loginId) async {
    final confirmed = await showOkCancelAlertDialog(
      context: context,
      useRootNavigator: false,
      title: 'Disconnect WhatsApp?',
      message: loginId == 'all'
          ? 'This will disconnect all WhatsApp bridge logins for this account.'
          : 'This will disconnect the selected WhatsApp login.',
      okLabel: 'Disconnect',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );
    if (confirmed != OkCancelResult.ok) return;
    try {
      await _service.logout(_client, provider: _provider, loginId: loginId);
      await _refresh();
      if (!mounted) return;
      _showSnackBar('WhatsApp disconnected.');
    } catch (error) {
      if (!mounted) return;
      await _showErrorDialog('Could not disconnect WhatsApp', error);
    }
  }

  Future<void> _showErrorDialog(String title, Object error) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: SelectableText(error.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<MessieBridgeState>(
      future: _bridgeStateFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Connections'),
              automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
              centerTitle: FluffyThemes.isColumnMode(context),
            ),
            body: MaxWidthBody(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link_off_outlined, size: 56),
                      const SizedBox(height: 16),
                      const Text(
                        'Could not load bridge connections.',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final state = snapshot.data;
        if (state == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Connections'),
              automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
              centerTitle: FluffyThemes.isColumnMode(context),
            ),
            body: const Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final connection = state.connection;
        final status = connection?.status;
        final statusLabel = switch (status) {
          api.BridgeConnectionStatusEnum.connected => 'Connected',
          api.BridgeConnectionStatusEnum.connecting => 'Connecting',
          _ => 'Not connected',
        };
        final flows = state.flows;
        final logins = state.logins;
        final network = state.whoami?.network;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Connections'),
            automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
            centerTitle: FluffyThemes.isColumnMode(context),
            actions: [
              IconButton(
                onPressed: _refresh,
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                MaxWidthBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.chat_bubble_outline,
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          network?.displayname ?? 'WhatsApp',
                                          style: theme.textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          logins.isEmpty
                                              ? 'Bridge your WhatsApp account into Matrix rooms managed by Messie.'
                                              : '${logins.length} active login${logins.length == 1 ? '' : 's'}',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Chip(label: Text(statusLabel)),
                                ],
                              ),
                              if (state.whoami?.bridgeBot != null ||
                                  state.whoami?.commandPrefix != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  [
                                    if (state.whoami?.bridgeBot != null)
                                      'Bridge bot: ${state.whoami!.bridgeBot}',
                                    if (state.whoami?.commandPrefix != null)
                                      'Command prefix: ${state.whoami!.commandPrefix}',
                                  ].join('\n'),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: flows
                                    .map(
                                      (flow) => FilledButton.icon(
                                        onPressed: () => _startFlow(flow),
                                        icon: const Icon(Icons.add_link_outlined),
                                        label: Text(flow.name),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (logins.isNotEmpty) ...[
                        Text(
                          'Active logins',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Column(
                            children: [
                              for (final login in logins)
                                ListTile(
                                  leading: const Icon(
                                    Icons.smartphone_outlined,
                                  ),
                                  title: Text(login.name),
                                  subtitle: Text(
                                    [
                                      if (login.profile?.displayName != null)
                                        login.profile!.displayName!,
                                      if (login.profile?.externalId != null)
                                        login.profile!.externalId!,
                                      if (login.state != null) login.state!,
                                    ].join(' • '),
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Disconnect',
                                    icon: const Icon(Icons.link_off_outlined),
                                    onPressed: () => _logout(login.id),
                                  ),
                                ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.delete_sweep_outlined),
                                title: const Text('Disconnect all'),
                                onTap: () => _logout('all'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BridgeDisplayAndWaitDialog extends StatefulWidget {
  const _BridgeDisplayAndWaitDialog({
    required this.initialStep,
    required this.selectedFlowId,
    required this.onPoll,
    required this.onMissingProcess,
  });

  final MessieBridgeProvisioningStep initialStep;
  final String selectedFlowId;
  final Future<MessieBridgeProvisioningStep> Function() onPoll;
  final Future<bool> Function() onMissingProcess;

  @override
  State<_BridgeDisplayAndWaitDialog> createState() =>
      _BridgeDisplayAndWaitDialogState();
}

class _BridgeDisplayDialogResult {
  const _BridgeDisplayDialogResult({this.step, this.restart = false});

  final MessieBridgeProvisioningStep? step;
  final bool restart;
}

class _BridgeDisplayAndWaitDialogState extends State<_BridgeDisplayAndWaitDialog> {
  late MessieBridgeProvisioningStep _step;
  Timer? _timer;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final nextStep = await widget.onPoll();
      if (!mounted) return;
      if (!nextStep.isDisplayAndWait) {
        _timer?.cancel();
        Navigator.of(
          context,
        ).pop(_BridgeDisplayDialogResult(step: nextStep));
        return;
      }
      setState(() => _step = nextStep);
    } catch (error) {
      if (!mounted) return;
      if (_isLoginNotFoundError(error)) {
        final connected = await widget.onMissingProcess();
        if (!mounted) return;
        if (connected) {
          _timer?.cancel();
          Navigator.of(context).pop(
            _BridgeDisplayDialogResult(
              step: MessieBridgeProvisioningStep(type: 'complete'),
            ),
          );
          return;
        }
      }
      setState(() => _error = _describeBridgeError(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool _isLoginNotFoundError(Object error) {
    if (error is! DioException) return false;
    if (error.response?.statusCode != 404) return false;
    final data = error.response?.data;
    if (data is Map) {
      final errcode = data['errcode']?.toString();
      final message = data['error']?.toString() ?? data['message']?.toString() ?? '';
      return errcode == 'M_NOT_FOUND' || message.contains('Login not found');
    }
    return error.toString().contains('Login not found');
  }

  String _describeBridgeError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final errorText = data['error']?.toString();
        final messageText = data['message']?.toString();
        if (errorText != null && errorText.isNotEmpty) return errorText;
        if (messageText != null && messageText.isNotEmpty) return messageText;
      }
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isCodeDisplay =
        (widget.selectedFlowId != 'qr' &&
            _step.data != null &&
            _step.data!.trim().isNotEmpty) ||
        _step.isCodeDisplay;
    final instructionText =
        _step.instructions ??
        _step.message ??
        (isCodeDisplay
            ? 'Enter this pairing code in the WhatsApp mobile app to finish linking.'
            : 'Scan the QR code in WhatsApp, then this dialog will continue automatically.');

    return AlertDialog.adaptive(
      title: const Text('Finish connecting WhatsApp'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (instructionText.isNotEmpty) ...[
              Text(
                instructionText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            if (_step.data != null && _step.data!.isNotEmpty)
              if (isCodeDisplay)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    _step.data!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PrettyQrView.data(data: _step.data!),
                )
            else if (_step.imageUrl != null)
              SelectableText(
                _step.imageUrl!,
                textAlign: TextAlign.center,
              ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              _loading
                  ? 'Waiting for the bridge to confirm the login...'
                  : isCodeDisplay
                  ? 'Keep this dialog open while WhatsApp finishes pairing.'
                  : 'Scan the QR code in WhatsApp, then this dialog will continue automatically.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (isCodeDisplay)
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              const _BridgeDisplayDialogResult(restart: true),
            ),
            child: const Text('New code'),
          ),
        TextButton(
          onPressed: _loading ? null : _poll,
          child: const Text('Refresh now'),
        ),
      ],
    );
  }
}
