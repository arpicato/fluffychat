import 'package:fluffychat/pages/image_viewer/image_viewer_policy.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    ImageViewerPolicy.debugPlatformOverride = null;
  });

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

  test('debug platform override drives viewer policy', () {
    ImageViewerPolicy.debugPlatformOverride = const ImageViewerPlatformOverride(
      isWeb: false,
      isDesktop: false,
      isMobile: true,
    );

    expect(ImageViewerPolicy.usesCustomZoomGestures, isFalse);
    expect(ImageViewerPolicy.pageViewPhysics(), isA<PageScrollPhysics>());
    expect(ImageViewerPolicy.showsMobileShareAction, isTrue);
  });
}
