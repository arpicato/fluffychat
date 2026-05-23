// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/environment_constants.dart';
import '../utils/fluffy_chat_tester.dart';

Future<void> finalLogout(WidgetTester widgetTester) =>
    widgetTester.startFluffyChatTest().then((tester) => tester.logout());

extension AuthFlows on FluffyChatTester {
  Future<void> login({
    String username = user1Name,
    String password = user1Pw,
  }) async {
    final homeserverUrl = 'http://$homeserver';
    await waitFor('Login with Matrix-ID');
    await tapOn('Login with Matrix-ID');
    await enterText(TextField, homeserverUrl, index: 0);
    await tapOn(homeserverUrl, index: 1);
    await tapOn('Continue');
    await enterText(TextField, username, index: 0);
    await enterText(TextField, password, index: 1);
    await tapOn('Login');
  }

  Future<void> logout() async {
    await ensureLoggedIn();
    await tapOn(Key('accounts_and_settings_buttons'));
    await tapOn(find.widgetWithText(PopupMenuItem<Object>, 'Settings'));
    await scrollUntilVisible(find.widgetWithText(ListTile, 'Logout'));
    await tapOn(find.widgetWithText(ListTile, 'Logout'));
    await tapOn(Key('ok_cancel_alert_dialog_ok_button'));
    await waitFor('Sign in');
  }

  Future<void> skipNoNotificationsDialog() async {
    if (await isVisible('Push notifications not available')) {
      await tapOn('Do not show again');
    }
  }

  Future<bool> ensureLoggedIn() async {
    var loginVisible = await isVisible('Login with Matrix-ID');
    if (!loginVisible) {
      await tester.pump(const Duration(seconds: 3));
      loginVisible = await isVisible('Login with Matrix-ID');
    }
    final signInVisible = loginVisible && await isVisible('Sign in');
    debugPrint(
      '[INTEGRATION TEST] ensureLoggedIn loginVisible=$loginVisible signInVisible=$signInVisible',
    );
    if (!loginVisible || !signInVisible) return false;

    debugPrint('[INTEGRATION TEST] ensureLoggedIn performing login flow');
    await login();
    await tapOn(CloseButton);
    await tapOn('Skip');
    await skipNoNotificationsDialog();
    debugPrint('[INTEGRATION TEST] ensureLoggedIn login flow complete');
    return true;
  }
}
