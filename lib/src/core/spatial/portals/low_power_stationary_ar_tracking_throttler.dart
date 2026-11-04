/// Task 1687: Throttles tracking update rate when device is static
class ArTrackingThrottler {
  int getTargetFps(bool isMoving) => isMoving ? 60 : 30;
}
