import 'package:shared_preferences/shared_preferences.dart';

class GamificationEngine {
  static const String _keyXp = 'user_xp_total';
  static const String _keyStreak = 'user_streak_days';
  static const String _keyLastSessionDate = 'user_last_session_epoch';

  static Future<int> getXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyXp) ?? 0;
  }

  static Future<int> addXp(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyXp) ?? 0;
    final updated = current + points;
    await prefs.setInt(_keyXp, updated);
    return updated;
  }

  static Future<int> recordDailyActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastEpoch = prefs.getInt(_keyLastSessionDate);
    int streak = prefs.getInt(_keyStreak) ?? 0;

    if (lastEpoch != null) {
      final lastDate = DateTime.fromMillisecondsSinceEpoch(lastEpoch);
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final differenceInDays = today.difference(lastDay).inDays;

      if (differenceInDays == 1) {
        streak += 1;
      } else if (differenceInDays > 1) {
        streak = 1; // إعادة تعيين بعد انقطاع
      }
    } else {
      streak = 1;
    }

    await prefs.setInt(_keyLastSessionDate, today.millisecondsSinceEpoch);
    await prefs.setInt(_keyStreak, streak);
    return streak;
  }
}
