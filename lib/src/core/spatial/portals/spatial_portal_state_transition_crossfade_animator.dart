/// Task 1696: Smooth crossfade shader transitioning from AR into full 3D
class PortalTransitionCrossfade {
  double getBlendFactor(int elapsedMs, int durationMs) => durationMs > 0 ? (elapsedMs / durationMs).clamp(0.0, 1.0) : 1.0;
}
