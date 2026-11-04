/// Task 1654: Device tilt angle to continuous walkthrough velocity mapper
class TiltWalkthroughPacer {
  double getWalkSpeed(double pitchDegrees) => (pitchDegrees / 45.0).clamp(-1.0, 1.0) * 2.5;
}
