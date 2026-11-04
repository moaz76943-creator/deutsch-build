/// Task 1411: Warm-start prior ability initializer from historical checkpoints
class WarmStartPriorInitializer {
  double getPriorTheta(int completedLessons, double avgAccuracy) => (completedLessons * 0.05 + avgAccuracy * 2.0 - 1.0).clamp(-3.0, 3.0);
}
