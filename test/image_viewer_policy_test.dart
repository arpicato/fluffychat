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
      expect(physics, isA<ImageViewerMobilePageScrollPhysics>());
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
    expect(
      ImageViewerPolicy.pageViewPhysics(),
      isA<ImageViewerMobilePageScrollPhysics>(),
    );
    expect(ImageViewerPolicy.showsMobileShareAction, isTrue);
  });

  test('mobile paging uses a higher drag start threshold', () {
    ImageViewerPolicy.debugPlatformOverride = const ImageViewerPlatformOverride(
      isWeb: false,
      isDesktop: false,
      isMobile: true,
    );

    final physics =
        ImageViewerPolicy.pageViewPhysics() as ImageViewerMobilePageScrollPhysics;

    expect(
      physics.dragStartDistanceMotionThreshold,
      ImageViewerMobilePageScrollPhysics.dragStartThreshold,
    );
  });

  test('mobile paging uses a snappier page spring', () {
    ImageViewerPolicy.debugPlatformOverride = const ImageViewerPlatformOverride(
      isWeb: false,
      isDesktop: false,
      isMobile: true,
    );

    final physics =
        ImageViewerPolicy.pageViewPhysics() as ImageViewerMobilePageScrollPhysics;

    expect(
      physics.spring.mass,
      ImageViewerMobilePageScrollPhysics.pageSpring.mass,
    );
    expect(
      physics.spring.stiffness,
      ImageViewerMobilePageScrollPhysics.pageSpring.stiffness,
    );
    expect(
      physics.spring.damping,
      ImageViewerMobilePageScrollPhysics.pageSpring.damping,
    );
  });

  test('mobile paging uses a looser settle tolerance', () {
    ImageViewerPolicy.debugPlatformOverride = const ImageViewerPlatformOverride(
      isWeb: false,
      isDesktop: false,
      isMobile: true,
    );

    final physics =
        ImageViewerPolicy.pageViewPhysics() as ImageViewerMobilePageScrollPhysics;

    expect(
      physics.toleranceFor(
        FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 100,
          pixels: 0,
          viewportDimension: 100,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        ),
      ),
      ImageViewerMobilePageScrollPhysics.pageTolerance,
    );
  });
}
