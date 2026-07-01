// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/l10n/l10n.dart';
import 'package:fluffychat/services/private_sticker_library_service.dart';
import 'package:flutter/material.dart';

class PrivateStickerPickerAppBarTitle extends StatelessWidget {
  final PrivateStickerLibraryLimits? limits;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreatePressed;

  const PrivateStickerPickerAppBarTitle({
    required this.limits,
    required this.onSearchChanged,
    required this.onCreatePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: L10n.of(context).search,
                    prefixIcon: const Icon(Icons.search_outlined),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add),
              tooltip: 'Create or import stickers',
            ),
          ],
        ),
        if (limits != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Saved stickers ${limits!.usedStickers}/${limits!.maxStickers}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
      ],
    );
  }
}
