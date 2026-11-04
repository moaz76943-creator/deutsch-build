/// Gamification Innovation: Adaptive Habit Retention & Shield
class GamifiedStreakShield {
  int calculateBonusXp(int consecutiveDays) => consecutiveDays * 15;
  bool isStreakProtected(int missedHours) => missedHours <= 24;
}
