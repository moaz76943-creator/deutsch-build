/// Daily activity record.
class StreakState {
  final int streakDays;
  final DateTime lastStudyDate;
  final int availableFreezes;
  final bool isProtectedToday;

  const StreakState({
    required this.streakDays,
    required this.lastStudyDate,
    required this.availableFreezes,
    this.isProtectedToday = false,
  });
}

/// Evaluates streak continuity and applies compassionate preservation guards.
class StreakSafeguardEngine {
  const StreakSafeguardEngine();

  /// Evaluates streak status on application cold-start given current date.
  StreakState evaluateStreak({
    required StreakState currentState,
    required DateTime currentDate,
  }) {
    final diffDays = currentDate.difference(currentState.lastStudyDate).inDays;

    if (diffDays <= 0) {
      // Same day study
      return currentState;
    } else if (diffDays == 1) {
      // Continuous consecutive day
      return StreakState(
        streakDays: currentState.streakDays + 1,
        lastStudyDate: currentDate,
        availableFreezes: currentState.availableFreezes,
      );
    } else if (diffDays == 2 && currentState.availableFreezes > 0) {
      // Missed 1 day, consume 1 freeze to protect streak
      return StreakState(
        streakDays: currentState.streakDays,
        lastStudyDate: currentDate,
        availableFreezes: currentState.availableFreezes - 1,
        isProtectedToday: true,
      );
    } else {
      // Streak broken, compassionate reset to 1
      return StreakState(
        streakDays: 1,
        lastStudyDate: currentDate,
        availableFreezes: currentState.availableFreezes,
      );
    }
  }
}
