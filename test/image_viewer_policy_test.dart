import 'package:fluffychat/pages/image_viewer/image_viewer_policy.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('custom zoom gestures match platform policy', () {
    expect(
      ImageViewerPolicy.usesCustomZoomGestures,
      PlatformInfos.isWeb || PlatformInfos.isDesktop,
    );
  });

  test('page view physics matches mobile paging policy', () {
    final physics = ImageViewerPolicy.pageViewPhysics();

    if (PlatformInfos.isMobile) {
      expect(physics, isA<PageScrollPhysics>());
    } else {
      expect(physics, isA<NeverScrollableScrollPhysics>());
    }
  });
}
