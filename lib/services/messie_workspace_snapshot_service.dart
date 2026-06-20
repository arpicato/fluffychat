import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'messie_calendar_service.dart';
import 'messie_todo_service.dart';

class MessieWorkspaceSnapshot {
  const MessieWorkspaceSnapshot({
    required this.savedAt,
    required this.todoLists,
    required this.upcomingCalendarEvents,
  });

  final DateTime savedAt;
  final List<MessieTodoList> todoLists;
  final List<MessieCalendarEvent> upcomingCalendarEvents;

  Map<String, Object?> toJson() => {
    'savedAt': savedAt.toUtc().toIso8601String(),
    'todoLists': todoLists.map((list) => list.toJson()).toList(),
    'upcomingCalendarEvents': upcomingCalendarEvents
        .map((event) => event.toJson())
        .toList(),
  };

  factory MessieWorkspaceSnapshot.fromJson(Map<String, Object?> json) {
    final todoLists = (json['todoLists'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) => MessieTodoList.fromJson(item.cast<String, Object?>()),
        )
        .toList();
    final upcomingCalendarEvents =
        (json['upcomingCalendarEvents'] as List? ?? const [])
            .whereType<Map>()
            .map(
              (item) => MessieCalendarEvent.fromJson(
                item.cast<String, Object?>(),
              ),
            )
            .where((event) => event.endsAt.isAfter(DateTime.now().toUtc()))
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return MessieWorkspaceSnapshot(
      savedAt:
          DateTime.tryParse(json['savedAt'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      todoLists: todoLists,
      upcomingCalendarEvents: upcomingCalendarEvents,
    );
  }
}

class MessieWorkspaceSnapshotService {
  static const _snapshotStorePrefix = 'messie_workspace_snapshot';

  const MessieWorkspaceSnapshotService();

  Future<MessieWorkspaceSnapshot?> read({
    required SharedPreferences store,
    required String userKey,
  }) async {
    final raw = store.getString(_snapshotKey(userKey));
    if (raw == null || raw.isEmpty) return null;
    try {
      return MessieWorkspaceSnapshot.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> write({
    required SharedPreferences store,
    required String userKey,
    required MessieWorkspaceSnapshot snapshot,
  }) =>
      store.setString(_snapshotKey(userKey), jsonEncode(snapshot.toJson()));

  Future<void> clear({
    required SharedPreferences store,
    required String userKey,
  }) =>
      store.remove(_snapshotKey(userKey));

  String _snapshotKey(String userKey) => '${_snapshotStorePrefix}_$userKey';
}
