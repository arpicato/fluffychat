import 'package:fluffychat/pages/image_viewer/image_viewer_policy.dart';
import 'package:fluffychat/widgets/zoomable_media_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    ImageViewerPolicy.debugPlatformOverride = null;
  });

  testWidgets('mouse wheel zoom scales interactive viewer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ZoomableMediaView(
            child: SizedBox(width: 200, height: 200, child: Placeholder()),
          ),
        ),
      ),
    );

    final interactiveViewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final controller = interactiveViewer.transformationController!;
    expect(controller.value.getMaxScaleOnAxis(), 1.0);

    final center = tester.getCenter(find.byType(InteractiveViewer));
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.handlePointerEvent(
      PointerScrollEvent(
        position: center,
        scrollDelta: const Offset(0, -120),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pump();

    expect(controller.value.getMaxScaleOnAxis(), greaterThan(1.0));
  });

  testWidgets('desktop wheel zoom uses a stronger zoom step', (tester) async {
    ImageViewerPolicy.debugPlatformOverride = const ImageViewerPlatformOverride(
      isWeb: false,
      isDesktop: true,
      isMobile: false,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ZoomableMediaView(
            child: SizedBox(width: 200, height: 200, child: Placeholder()),
          ),
        ),
      ),
    );

    final interactiveViewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final controller = interactiveViewer.transformationController!;

    final center = tester.getCenter(find.byType(InteractiveViewer));
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.handlePointerEvent(
      PointerScrollEvent(
        position: center,
        scrollDelta: const Offset(0, -120),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pump();

    expect(controller.value.getMaxScaleOnAxis(), greaterThan(1.15));
  });

  test('desktop wheel tuning is stronger than web', () {
    ImageViewerPolicy.debugPlatformOverride = const ImageViewerPlatformOverride(
      isWeb: true,
      isDesktop: false,
      isMobile: false,
    );
    final webMultiplier = ImageViewerPolicy.wheelStepMultiplier;

    ImageViewerPolicy.debugPlatformOverride = const ImageViewerPlatformOverride(
      isWeb: false,
      isDesktop: true,
      isMobile: false,
    );
    final desktopMultiplier = ImageViewerPolicy.wheelStepMultiplier;

    expect(desktopMultiplier, greaterThan(webMultiplier));
  });

  testWidgets('mouse wheel zoom keeps pointer scene point stable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ZoomableMediaView(
            child: SizedBox(width: 600, height: 400, child: Placeholder()),
          ),
        ),
      ),
    );

    final interactiveViewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final controller = interactiveViewer.transformationController!;

    final topLeft = tester.getTopLeft(find.byType(InteractiveViewer));
    final pointer = topLeft + const Offset(80, 60);
    final sceneBefore = controller.toScene(pointer);

    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.handlePointerEvent(
      PointerScrollEvent(
        position: pointer,
        scrollDelta: const Offset(0, -80),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pump();

    final sceneAfter = controller.toScene(pointer);
    expect((sceneAfter - sceneBefore).distance, lessThan(0.01));
  });
}
