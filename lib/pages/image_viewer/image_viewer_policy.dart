// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/material.dart';

class ImageViewerPolicy {
  static bool get usesCustomZoomGestures =>
      PlatformInfos.isWeb || PlatformInfos.isDesktop;

  static ScrollPhysics pageViewPhysics() => PlatformInfos.isMobile
      ? const PageScrollPhysics()
      : const NeverScrollableScrollPhysics();
}
