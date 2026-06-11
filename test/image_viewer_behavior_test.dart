import 'package:fluffychat/pages/image_viewer/image_viewer_policy.dart';
import 'package:fluffychat/widgets/zoomable_media_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ViewerHarness extends StatelessWidget {
  const _ViewerHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PageView(
          scrollDirection: Axis.vertical,
          physics: ImageViewerPolicy.pageViewPhysics(),
          children: const [
            ZoomableMediaView(
              child: SizedBox(width: 300, height: 300, child: Placeholder()),
            ),
            Center(child: Text('Second page', textDirection: TextDirection.ltr)),
          ],
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

    expect(find.byType(Placeholder), findsOneWidget);
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.physics, isA<PageScrollPhysics>());
    expect(find.text('Second page'), findsNothing);

    await tester.drag(find.byType(PageView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.byType(Placeholder), findsNothing);
    expect(find.text('Second page'), findsOneWidget);
  });

  testWidgets('mobile pinch zoom scales the image viewer', (tester) async {
    await tester.pumpWidget(const _ViewerHarness());

    final interactiveViewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final controller = interactiveViewer.transformationController!;
    expect(controller.value.getMaxScaleOnAxis(), 1.0);
    expect(interactiveViewer.scaleEnabled, isTrue);

    final center = tester.getCenter(find.byType(InteractiveViewer));
    final gesture1 = await tester.createGesture(pointer: 1);
    final gesture2 = await tester.createGesture(pointer: 2);
    await gesture1.down(center + const Offset(-40, 0));
    await gesture2.down(center + const Offset(40, 0));
    await tester.pump();

    await gesture1.moveTo(center + const Offset(-80, 0));
    await gesture2.moveTo(center + const Offset(80, 0));
    await tester.pump();

    await gesture1.up();
    await gesture2.up();
    await tester.pumpAndSettle();

    expect(controller.value.getMaxScaleOnAxis(), greaterThan(1.0));
  });
}
