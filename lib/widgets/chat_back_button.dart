// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

class ChatBackButton extends StatelessWidget {
  const ChatBackButton({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: BackButton(
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.maybePop(context);
      },
    ),
  );
}
