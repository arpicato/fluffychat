import 'package:flutter/foundation.dart';

enum MessieWorkspaceRefreshKind { full, todoLists, todoItems, calendar }

class MessieWorkspaceRefreshSignal {
  const MessieWorkspaceRefreshSignal({required this.kind, this.listId});

  final MessieWorkspaceRefreshKind kind;
  final String? listId;
}

class MessieWorkspaceRefresh extends ChangeNotifier {
  MessieWorkspaceRefresh._();

  static final MessieWorkspaceRefresh instance = MessieWorkspaceRefresh._();

  int _generation = 0;
  int get generation => _generation;
  MessieWorkspaceRefreshSignal _signal = const MessieWorkspaceRefreshSignal(
    kind: MessieWorkspaceRefreshKind.full,
  );
  MessieWorkspaceRefreshSignal get signal => _signal;

  void bump([
    MessieWorkspaceRefreshSignal signal = const MessieWorkspaceRefreshSignal(
      kind: MessieWorkspaceRefreshKind.full,
    ),
  ]) {
    _signal = signal;
    _generation += 1;
    notifyListeners();
  }
}
