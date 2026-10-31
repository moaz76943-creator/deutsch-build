import 'package:shared_preferences/shared_preferences.dart';

class StreakEngine {
  static const String _kLastActiveDate = 'streak_last_active_date';
  static const String _kCurrentStreak = 'streak_current_count';
  static const String _kFreezesAvailable = 'streak_freezes_available';

  static Future<Map<String, dynamic>> updateDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastDateStr = prefs.getString(_kLastActiveDate);
    int currentStreak = prefs.getInt(_kCurrentStreak) ?? 0;
    int freezes = prefs.getInt(_kFreezesAvailable) ?? 2; // يومين سماح شهرياً

    if (lastDateStr == null) {
      currentStreak = 1;
    } else {
      final lastDate = DateTime.parse(lastDateStr);
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final difference = today.difference(lastDay).inDays;

      if (difference == 1) {
        currentStreak += 1;
      } else if (difference > 1) {
        if (difference == 2 && freezes > 0) {
          // استهلاك تجميد السلسلة بدلاً من تصفيرها
          freezes -= 1;
          currentStreak += 1;
        } else {
          currentStreak = 1;
        }
      }
    }

    await prefs.setString(_kLastActiveDate, today.toIso8601String());
    await prefs.setInt(_kCurrentStreak, currentStreak);
    await prefs.setInt(_kFreezesAvailable, freezes);

    return {
      'streak': currentStreak,
      'freezesLeft': freezes,
      'protected': true,
    };
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kCurrentStreak) ?? 0;
  }

  static Future<int> getFreezesAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kFreezesAvailable) ?? 2;
  }
}
