/// Task 1871: GPU raster thread jank tracker ensuring consistent 60/120 FPS
class GpuJankFrameTracker {
  bool isSmooth(int droppedFrames, int totalFrames) => totalFrames > 0 && (droppedFrames / totalFrames) < 0.01;
}
