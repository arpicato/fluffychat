// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/pages/calendar/calendar_event_detail.dart';
import 'package:fluffychat/pages/todos/todo_list_detail.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

typedef RoutesPageBuilder = Page<dynamic> Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

Page<dynamic> buildMessieCalendarEventDetailPage(
  BuildContext context,
  GoRouterState state,
  RoutesPageBuilder defaultPageBuilder,
) {
  final extra = state.extra;
  final initialTitle =
      extra is Map<String, Object?> ? extra['title'] as String? : null;
  final initialSourceDisplayName =
      extra is Map<String, Object?>
      ? extra['sourceDisplayName'] as String?
      : null;
  return defaultPageBuilder(
    context,
    state,
    CalendarEventDetailPage(
      eventId: state.pathParameters['eventId']!,
      initialTitle: initialTitle,
      initialSourceDisplayName: initialSourceDisplayName,
    ),
  );
}

Page<dynamic> buildMessieTodoListDetailPage(
  BuildContext context,
  GoRouterState state,
  RoutesPageBuilder defaultPageBuilder,
) {
  final extra = state.extra;
  final initialTitle =
      extra is Map<String, Object?> ? extra['title'] as String? : null;
  final initialDescription =
      extra is Map<String, Object?> ? extra['description'] as String? : null;
  return defaultPageBuilder(
    context,
    state,
    TodoListDetailPage(
      listId: state.pathParameters['listId']!,
      initialTitle: initialTitle,
      initialDescription: initialDescription,
    ),
  );
}
