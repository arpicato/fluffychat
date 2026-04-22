import 'package:flutter/foundation.dart';

class MessieWorkspaceRefresh extends ChangeNotifier {
  MessieWorkspaceRefresh._();

  static final MessieWorkspaceRefresh instance = MessieWorkspaceRefresh._();

  int _generation = 0;
  int get generation => _generation;

  void bump() {
    _generation += 1;
    notifyListeners();
  }
}

