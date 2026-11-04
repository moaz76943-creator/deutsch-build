/// Task 1647: Haptic boundary bump vibration alerting room limits
class BoundaryBumpFeedback {
  bool shouldVibrate(double posX, double roomBoundX) => posX.abs() >= roomBoundX;
}
