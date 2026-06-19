import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Determines whether a local [offset] within [paragraph] lands on an actual
/// rendered glyph (as opposed to empty space such as the area to the right of
/// a short line that is followed by a longer line).
///
/// Returns `true` when the point is on a glyph, `false` when it is on empty
/// space inside the paragraph's box.
bool offsetHitsGlyph(RenderParagraph paragraph, Offset offset) {
  final size = paragraph.size;
  if (offset.dx < 0 ||
      offset.dy < 0 ||
      offset.dx > size.width ||
      offset.dy > size.height) {
    return false;
  }

  final position = paragraph.getPositionForOffset(offset);

  // Build a selection covering the single character/grapheme at this position
  // and inspect its bounding boxes. If the tap is within one of those boxes
  // (with a small vertical tolerance for line height) it is on a glyph.
  final textRange = paragraph.getWordBoundary(position);
  if (textRange.isCollapsed) {
    return false;
  }

  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: textRange.start, extentOffset: textRange.end),
  );
  if (boxes.isEmpty) {
    return false;
  }

  for (final box in boxes) {
    final rect = box.toRect();
    // Horizontal containment is the decisive signal: empty trailing space on a
    // line falls outside every glyph box's right edge. Vertical containment is
    // checked with a tolerance so taps anywhere in the line's height count.
    if (offset.dx >= rect.left &&
        offset.dx <= rect.right &&
        offset.dy >= rect.top &&
        offset.dy <= rect.bottom) {
      return true;
    }
  }
  return false;
}

/// Walks the render subtree under [root] looking for [RenderParagraph]s and
/// returns `true` if any of them report a glyph hit at the global [globalPoint].
bool subtreeHasGlyphAt(RenderObject root, Offset globalPoint) {
  return probeSubtreeText(root, globalPoint).glyphHit;
}

/// Result of probing a render subtree for text under a global point.
class SubtreeTextProbe {
  const SubtreeTextProbe({required this.hasParagraph, required this.glyphHit});

  /// Whether the subtree contains any rendered text at all.
  final bool hasParagraph;

  /// Whether the point landed on an actual glyph.
  final bool glyphHit;
}

/// Walks the render subtree under [root], reporting whether it contains any
/// text ([SubtreeTextProbe.hasParagraph]) and whether the global [globalPoint]
/// lands on a glyph ([SubtreeTextProbe.glyphHit]).
///
/// Non-text bubbles (images, video, files) contain no [RenderParagraph], so
/// `hasParagraph` is false and callers should stay inert, leaving the content's
/// own tap handling intact.
SubtreeTextProbe probeSubtreeText(RenderObject root, Offset globalPoint) {
  var hasParagraph = false;
  var glyphHit = false;

  void visit(RenderObject node) {
    if (node is RenderParagraph) {
      hasParagraph = true;
      if (!glyphHit) {
        final transform = node.getTransformTo(null);
        final inverted = Matrix4.tryInvert(transform);
        if (inverted != null) {
          final local = MatrixUtils.transformPoint(inverted, globalPoint);
          if (offsetHitsGlyph(node, local)) {
            glyphHit = true;
          }
        }
      }
    }
    node.visitChildren(visit);
  }

  visit(root);
  return SubtreeTextProbe(hasParagraph: hasParagraph, glyphHit: glyphHit);
}
