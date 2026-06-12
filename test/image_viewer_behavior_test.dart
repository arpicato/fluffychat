import 'package:fluffychat/pages/image_viewer/image_viewer_policy.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ViewerHarness extends StatelessWidget {
  const _ViewerHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PhotoViewGallery.builder(
          scrollDirection: Axis.vertical,
          scrollPhysics: ImageViewerPolicy.pageViewPhysics(),
          itemCount: 2,
          builder: (context, index) => PhotoViewGalleryPageOptions.customChild(
            minScale: PhotoViewComputedScale.contained,
            initialScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            child: SizedBox(
              width: 300,
              height: 300,
              child: Center(
                child: Text(
                  index == 0 ? 'First page' : 'Second page',
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  setUp(() {
    ImageViewerPolicy.debugPlatformOverride = const ImageViewerPlatformOverride(
      isWeb: false,
      isDesktop: false,
      isMobile: true,
    );
  });

  tearDown(() {
    ImageViewerPolicy.debugPlatformOverride = null;
  });

  testWidgets('mobile viewer pages vertically between images', (tester) async {
    await tester.pumpWidget(const _ViewerHarness());

    expect(find.text('First page'), findsOneWidget);
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.physics, isA<ImageViewerMobilePageScrollPhysics>());
    expect(
      pageView.physics!.dragStartDistanceMotionThreshold,
      ImageViewerMobilePageScrollPhysics.dragStartThreshold,
    );

    await tester.drag(find.byType(PageView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('First page'), findsNothing);
    expect(find.text('Second page'), findsOneWidget);
  });

  testWidgets('mobile viewer uses photo view for zoomable content', (
    tester,
  ) async {
    await tester.pumpWidget(const _ViewerHarness());

    expect(find.byType(PhotoView), findsWidgets);
  });
}
