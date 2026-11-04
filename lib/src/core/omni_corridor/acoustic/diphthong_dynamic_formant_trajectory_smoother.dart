/// Task 1975: Formant trajectory interpolator smoothing dynamic diphthong transitions
class DiphthongTrajectorySmoother {
  List> interpolateTrajectory(Map<String, double> start, Map<String, double> end, int steps) {
    return List.generate(steps, (i) => {'F1': start['F1']! + (end['F1']! - start['F1']!) * (i / steps)});
  }
}
