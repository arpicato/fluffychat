import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/services/backend_session_service.dart';
import 'package:fluffychat/services/messie_bridge_service.dart';
import 'package:fluffychat/services/messie_calendar_service.dart';
import 'package:fluffychat/services/messie_todo_service.dart';
import 'package:fluffychat/services/messie_workspace_refresh.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messie_api/messie_api.dart' as api;

import 'workspace_home.dart';

class WorkspaceHomePageView extends StatelessWidget {
  WorkspaceHomePageView(this.controller, {super.key});

  final WorkspaceHomePageController controller;
  final BackendSessionService _sessionService = BackendSessionService();
  final MessieTodoService _todoService = MessieTodoService();
  final MessieCalendarService _calendarService = MessieCalendarService();
  final MessieBridgeService _bridgeService = MessieBridgeService();

  Future<_WorkspaceHomeData> _load(BuildContext context) async {
    final matrix = Matrix.of(context);
    final session = await _sessionService.ensureSession(
      matrix.client,
      matrix.store,
    );
    final todoListsFuture = _todoService.getTodoLists(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.token,
      userId: session.userId,
    );
    final calendarEventsFuture = _calendarService.getUpcomingCalendarEvents(
      apiBaseUrl: BackendSessionService.defaultApiBaseUrl,
      jwt: session.token,
      limit: 5,
    );
    final bridgeStateFuture = _bridgeService.loadState(matrix.client);
    final results = await Future.wait([
      todoListsFuture,
      calendarEventsFuture,
      bridgeStateFuture,
    ]);
    return _WorkspaceHomeData(
      todoLists: results[0] as List<MessieTodoList>,
      calendarEvents: results[1] as List<MessieCalendarEvent>,
      bridgeState: results[2] as MessieBridgeState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _WorkspaceHomeRefreshScope(
      onRefresh: controller.refresh,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workspace'),
          automaticallyImplyLeading: !FluffyThemes.isColumnMode(context),
          centerTitle: FluffyThemes.isColumnMode(context),
          actions: [
            IconButton(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh workspace',
            ),
          ],
        ),
        body: FutureBuilder<_WorkspaceHomeData>(
          future: _load(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return MaxWidthBody(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load workspace data from Messie.',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: controller.refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final data = snapshot.requireData;
            return MaxWidthBody(
              innerPadding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WorkspaceSectionCard(
                    title: 'Calendar',
                    icon: Icons.calendar_month_outlined,
                    actionLabel: 'Open calendar',
                    onAction: () => context.go('/rooms/calendar'),
                    child: data.calendarEvents.isEmpty
                        ? const _EmptySectionState(
                            message:
                                'No upcoming events in the next sync window.',
                          )
                        : Column(
                            children: data.calendarEvents
                                .map(
                                  (event) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () => context.go(
                                      '/rooms/calendar/events/${event.id}',
                                      extra: <String, Object?>{
                                        'title': event.title,
                                        'sourceDisplayName':
                                            event.sourceDisplayName,
                                      },
                                    ),
                                    leading: const Icon(
                                      Icons.event_available_outlined,
                                    ),
                                    title: Text(
                                      event.title.isEmpty
                                          ? 'Untitled event'
                                          : event.title,
                                    ),
                                    subtitle: Text(
                                      '${_formatDateTime(event.startsAt)} · ${event.sourceDisplayName}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  _WorkspaceSectionCard(
                    title: 'Todos',
                    icon: Icons.checklist_rtl_outlined,
                    actionLabel: 'Open todos',
                    onAction: () => context.go('/rooms/todos'),
                    child: data.todoLists.isEmpty
                        ? const _EmptySectionState(
                            message: 'No todo lists yet.',
                          )
                        : Column(
                            children: data.todoLists
                                .take(5)
                                .map(
                                  (todoList) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () => context.go(
                                      '/rooms/todos/${todoList.id}',
                                      extra: <String, Object?>{
                                        'title': todoList.title,
                                        'description': todoList.description,
                                      },
                                    ),
                                    leading: const Icon(
                                      Icons.checklist_outlined,
                                    ),
                                    title: Text(
                                      todoList.title.isEmpty
                                          ? 'Untitled list'
                                          : todoList.title,
                                    ),
                                    subtitle: Text(
                                      todoList.description.isEmpty
                                          ? 'No description'
                                          : todoList.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  _WorkspaceSectionCard(
                    title: 'Connections',
                    icon: Icons.link_outlined,
                    actionLabel: 'Manage connections',
                    onAction: () => context.go('/rooms/settings/connections'),
                    child: _BridgeStatusSummary(data.bridgeState),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day ${local.year} $hour:$minute';
  }
}

class _WorkspaceHomeRefreshScope extends StatefulWidget {
  const _WorkspaceHomeRefreshScope({
    required this.onRefresh,
    required this.child,
  });

  final VoidCallback onRefresh;
  final Widget child;

  @override
  State<_WorkspaceHomeRefreshScope> createState() =>
      _WorkspaceHomeRefreshScopeState();
}

class _WorkspaceHomeRefreshScopeState
    extends State<_WorkspaceHomeRefreshScope> {
  @override
  void initState() {
    super.initState();
    MessieWorkspaceRefresh.instance.addListener(widget.onRefresh);
  }

  @override
  void didUpdateWidget(covariant _WorkspaceHomeRefreshScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onRefresh == widget.onRefresh) return;
    MessieWorkspaceRefresh.instance.removeListener(oldWidget.onRefresh);
    MessieWorkspaceRefresh.instance.addListener(widget.onRefresh);
  }

  @override
  void dispose() {
    MessieWorkspaceRefresh.instance.removeListener(widget.onRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _WorkspaceSectionCard extends StatelessWidget {
  const _WorkspaceSectionCard({
    required this.title,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    required this.child,
  });

  final String title;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptySectionState extends StatelessWidget {
  const _EmptySectionState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _BridgeStatusSummary extends StatelessWidget {
  const _BridgeStatusSummary(this.state);

  final MessieBridgeState state;

  @override
  Widget build(BuildContext context) {
    final connection = state.connection;
    final isConnected =
        connection?.status == api.BridgeConnectionStatusEnum.connected ||
        state.logins.isNotEmpty;
    final statusLabel = switch (connection?.status) {
      api.BridgeConnectionStatusEnum.connected => 'Connected',
      api.BridgeConnectionStatusEnum.connecting => 'Connecting',
      api.BridgeConnectionStatusEnum.notConnected => 'Disconnected',
      _ => 'Not configured',
    };
    final loginLabel = state.logins.length == 1
        ? '1 linked account'
        : '${state.logins.length} linked accounts';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isConnected ? Icons.check_circle_outline : Icons.link_off_outlined,
        color: isConnected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      title: Text(statusLabel),
      subtitle: Text(loginLabel),
    );
  }
}

class _WorkspaceHomeData {
  const _WorkspaceHomeData({
    required this.todoLists,
    required this.calendarEvents,
    required this.bridgeState,
  });

  final List<MessieTodoList> todoLists;
  final List<MessieCalendarEvent> calendarEvents;
  final MessieBridgeState bridgeState;
}
