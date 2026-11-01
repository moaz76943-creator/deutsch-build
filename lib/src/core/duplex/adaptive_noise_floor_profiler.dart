import 'dart:math' as math;

class AdaptiveNoiseFloorProfiler {
  double currentFloorRms;
  AdaptiveNoiseFloorProfiler({this.currentFloorRms = 0.02});

  void updateNoiseFloor(double frameRms) {
    // Leaky integrator tracker
    currentFloorRms = (0.95 * currentFloorRms) + (0.05 * math.min(currentFloorRms * 1.5, frameRms));
  }
}
