/// Task 1433: Pitch reset detector identifying prosodic phrase boundaries
class PitchResetBoundaryDetector {
  bool isPhraseBoundary(double deltaF0) => deltaF0.abs() > 40.0;
}
