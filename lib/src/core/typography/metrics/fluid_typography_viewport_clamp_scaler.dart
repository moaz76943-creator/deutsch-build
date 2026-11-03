/// Task 1263: Fluid typography clamp() scaler between viewports
class FluidTypographyScaler {
  double clampScale(double viewportWidth, double minSize, double maxSize) {
    double scale = minSize + (viewportWidth / 100.0);
    return scale.clamp(minSize, maxSize);
  }
}
