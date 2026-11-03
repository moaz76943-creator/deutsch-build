/// Task 1196: Measures continuous seconds of fluent spoken discourse
class FluencyStreakTracker {
  int currentStreakSeconds = 0;
  void recordFluentSecond() => currentStreakSeconds++;
  void reset() => currentStreakSeconds = 0;
}
