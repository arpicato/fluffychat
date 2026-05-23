// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:fluffychat/pages/calendar/calendar_event_detail.dart';
import 'package:fluffychat/pages/bridge_connections/bridge_connections.dart';
import 'package:fluffychat/pages/calendar/calendar.dart';
import 'package:fluffychat/pages/messie_auth/login/messie_login.dart';
import 'package:fluffychat/pages/messie_auth/register/messie_register.dart';
import 'package:fluffychat/pages/messie_auth/sign_in/messie_sign_in_page.dart';
import 'package:fluffychat/pages/todos/todo_list_detail.dart';
import 'package:fluffychat/pages/todos/todos.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

typedef RoutesPageBuilder = Page<dynamic> Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

GoRoute buildMessieSignInRoute(
  FutureOr<String?> Function(BuildContext, GoRouterState) redirect,
  RoutesPageBuilder defaultPageBuilder,
) => GoRoute(
  path: 'sign_in',
  pageBuilder: (context, state) => defaultPageBuilder(
    context,
    state,
    MessieSignInPage(signUp: false),
  ),
  redirect: redirect,
);

GoRoute buildMessieSignUpRoute(
  FutureOr<String?> Function(BuildContext, GoRouterState) redirect,
  RoutesPageBuilder defaultPageBuilder,
) => GoRoute(
  path: 'sign_up',
  pageBuilder: (context, state) => defaultPageBuilder(
    context,
    state,
    MessieSignInPage(signUp: true),
  ),
  redirect: redirect,
);

GoRoute buildMessieLoginRoute(
  FutureOr<String?> Function(BuildContext, GoRouterState) redirect,
  RoutesPageBuilder defaultPageBuilder,
) => GoRoute(
  path: 'login',
  pageBuilder: (context, state) => defaultPageBuilder(
    context,
    state,
    MessieLogin(client: state.extra as Client),
  ),
  redirect: redirect,
);

GoRoute buildMessieRegisterRoute(
  FutureOr<String?> Function(BuildContext, GoRouterState) redirect,
  RoutesPageBuilder defaultPageBuilder,
) => GoRoute(
  path: 'register',
  pageBuilder: (context, state) => defaultPageBuilder(
    context,
    state,
    MessieRegister(client: state.extra as Client),
  ),
  redirect: redirect,
);

GoRoute buildMessieCalendarRoute(
  FutureOr<String?> Function(BuildContext, GoRouterState) redirect,
  RoutesPageBuilder defaultPageBuilder,
) => GoRoute(
  path: 'calendar',
  pageBuilder: (context, state) =>
      defaultPageBuilder(context, state, const CalendarPage()),
  routes: [
    GoRoute(
      path: 'events/:eventId',
      pageBuilder: (context, state) => buildMessieCalendarEventDetailPage(
        context,
        state,
        defaultPageBuilder,
      ),
      redirect: redirect,
    ),
  ],
  redirect: redirect,
);

GoRoute buildMessieTodosRoute(
  FutureOr<String?> Function(BuildContext, GoRouterState) redirect,
  RoutesPageBuilder defaultPageBuilder,
) => GoRoute(
  path: 'todos',
  pageBuilder: (context, state) =>
      defaultPageBuilder(context, state, const TodosPage()),
  redirect: redirect,
);

GoRoute buildMessieTodoListRoute(
  FutureOr<String?> Function(BuildContext, GoRouterState) redirect,
  RoutesPageBuilder defaultPageBuilder,
) => GoRoute(
  path: 'todos/:listId',
  pageBuilder: (context, state) =>
      buildMessieTodoListDetailPage(context, state, defaultPageBuilder),
  redirect: redirect,
);

GoRoute buildMessieConnectionsRoute(
  FutureOr<String?> Function(BuildContext, GoRouterState) redirect,
  RoutesPageBuilder defaultPageBuilder,
) => GoRoute(
  path: 'connections',
  pageBuilder: (context, state) =>
      defaultPageBuilder(context, state, const BridgeConnectionsPage()),
  redirect: redirect,
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
