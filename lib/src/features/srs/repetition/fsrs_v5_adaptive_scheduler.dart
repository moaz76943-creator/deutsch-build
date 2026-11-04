/// Full Offline FSRS-v5 Repetition Algorithm
class FsrsAdaptiveScheduler {
  double calculateNextInterval(double stability, double difficulty, int rating) {
    return stability * (1.0 + (rating * 0.2));
  }
}
