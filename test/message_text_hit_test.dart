import 'package:fluffychat/pages/chat/message_text_hit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Renders a paragraph whose first line is short ("hi") and second line is
  // long, so there is real empty space to the right of the first line, inside
  // the paragraph's bounding box.
  Future<RenderParagraph> pumpParagraph(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: Text(
                'hi\nthis is a much longer second line of text here',
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      ),
    );
    final element = tester.element(find.byType(Text));
    final ro = element.renderObject;
    return _findParagraph(ro!);
  }

  testWidgets('tap on glyph reports a glyph hit', (tester) async {
    final paragraph = await pumpParagraph(tester);
    // Top-left, on the "h" of "hi".
    final hit = offsetHitsGlyph(paragraph, const Offset(3, 6));
    expect(hit, isTrue, reason: 'tapping directly on a glyph should report a hit');
  });

  testWidgets('tap on empty space right of short line reports no glyph', (tester) async {
    final paragraph = await pumpParagraph(tester);
    // Far right on the first line ("hi" only occupies a few px); y stays on line 1.
    final hit = offsetHitsGlyph(paragraph, const Offset(280, 6));
    expect(hit, isFalse, reason: 'empty space right of the short line should NOT be a glyph hit');
  });

  testWidgets('tap on glyph in the long second line reports a hit', (tester) async {
    final paragraph = await pumpParagraph(tester);
    final size = paragraph.size;
    // Lower-left should be on the long line's text.
    final hit = offsetHitsGlyph(paragraph, Offset(4, size.height - 4));
    expect(hit, isTrue, reason: 'tapping on the long line text should report a hit');
  });
}

RenderParagraph _findParagraph(RenderObject root) {
  RenderParagraph? result;
  void visit(RenderObject node) {
    if (result != null) return;
    if (node is RenderParagraph) {
      result = node;
      return;
    }
    node.visitChildren(visit);
  }

  visit(root);
  return result!;
}
