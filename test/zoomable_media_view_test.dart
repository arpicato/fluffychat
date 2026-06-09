import 'package:fluffychat/widgets/zoomable_media_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
