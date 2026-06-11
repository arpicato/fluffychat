// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/material.dart';

class ImageViewerMobilePageScrollPhysics extends PageScrollPhysics {
  const ImageViewerMobilePageScrollPhysics({super.parent});

  static const dragStartThreshold = 72.0;

  @override
  ImageViewerMobilePageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ImageViewerMobilePageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double? get dragStartDistanceMotionThreshold => dragStartThreshold;
}

class ImageViewerPlatformOverride {
  const ImageViewerPlatformOverride({
    required this.isWeb,
    required this.isDesktop,
    required this.isMobile,
  });

  final bool isWeb;
  final bool isDesktop;
  final bool isMobile;
}

class ImageViewerPolicy {
  static ImageViewerPlatformOverride? debugPlatformOverride;
  static const webWheelPixelsPerStep = 120.0;
  static const webWheelStepMultiplier = 1.18;
  static const desktopWheelPixelsPerStep = 120.0;
  static const desktopWheelStepMultiplier = 1.32;

  static bool get _isWeb => debugPlatformOverride?.isWeb ?? PlatformInfos.isWeb;

  static bool get _isDesktop =>
      debugPlatformOverride?.isDesktop ?? PlatformInfos.isDesktop;

  static bool get _isMobile =>
      debugPlatformOverride?.isMobile ?? PlatformInfos.isMobile;

  static bool get usesCustomZoomGestures => _isWeb || _isDesktop;

  static bool get showsMobileShareAction => _isMobile;

  static bool get isWeb => _isWeb;

  static double get wheelPixelsPerStep =>
      _isWeb ? webWheelPixelsPerStep : desktopWheelPixelsPerStep;

  static double get wheelStepMultiplier =>
      _isWeb ? webWheelStepMultiplier : desktopWheelStepMultiplier;

  static ScrollPhysics pageViewPhysics() => _isMobile
      ? const ImageViewerMobilePageScrollPhysics()
      : const NeverScrollableScrollPhysics();
}
