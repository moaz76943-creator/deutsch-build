class HabitStreakManager {
  static bool canUseFreezeShield({
    required int availableShields,
    required DateTime lastActiveDate,
  }) {
    final now = DateTime.now();
    final difference = now.difference(lastActiveDate).inDays;
    return difference == 2 && availableShields > 0;
  }

  static int updateStreak({
    required DateTime lastActiveDate,
    required int currentStreak,
    required bool usedShield,
  }) {
    final now = DateTime.now();
    final difference = now.difference(lastActiveDate).inDays;

    if (difference <= 1) return currentStreak + 1;
    if (usedShield) return currentStreak;
    return 1;
  }
}
