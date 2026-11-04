/// Task 1642: 6-DOF orbital touch camera controller for room navigation
class SpatialCameraController {
  double yaw = 0.0;
  double pitch = 0.0;
  void rotate(double dx, double dy) { yaw += dx * 0.5; pitch = (pitch + dy * 0.5).clamp(-85.0, 85.0); }
}
