/// Task 1232: Calculates tight bounding boxes to prevent glyph clipping
class GlyphTightClippingGuard {
  bool isWithinBounds(double yMin, double yMax, double clipHeight) => (yMax - yMin) <= clipHeight;
}
