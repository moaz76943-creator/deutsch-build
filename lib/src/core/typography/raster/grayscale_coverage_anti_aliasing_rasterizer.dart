/// Task 1237: 8-bit grayscale pixel coverage calculation for soft antialiasing
class GrayscaleCoverageRasterizer {
  int calculatePixelCoverage(double area) => (area.clamp(0.0, 1.0) * 255).round();
}
