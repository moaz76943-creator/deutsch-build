/// Pure daily-learning streak calculation with explicit timezone handling.
final class DailyStreakEngine {
  const DailyStreakEngine();

  int currentStreak(
    Iterable<DateTime> activityTimesUtc, {
    required DateTime nowUtc,
    int timezoneOffsetMinutes = 0,
  }) {
    if (!nowUtc.isUtc) {
      throw ArgumentError('nowUtc must be in UTC');
    }
    final offset = timezoneOffsetMinutes.clamp(-840, 840).toInt();
    final today = _localDay(nowUtc, offset);
    final uniqueDays = <DateTime>{
      for (final timestamp in activityTimesUtc)
        if (!timestamp.toUtc().isAfter(nowUtc))
          _localDay(timestamp.toUtc(), offset),
    }.toList()
      ..sort();

    if (uniqueDays.isEmpty) return 0;

    final latest = uniqueDays.last;
    final gapFromToday = today.difference(latest).inDays;
    if (gapFromToday > 1) return 0;

    var streak = 1;
    var cursor = latest;
    for (var index = uniqueDays.length - 2; index >= 0; index--) {
      final candidate = uniqueDays[index];
      final gap = cursor.difference(candidate).inDays;
      if (gap == 0) continue;
      if (gap != 1) break;
      streak++;
      cursor = candidate;
    }
    return streak;
  }

  DateTime _localDay(DateTime utc, int offsetMinutes) {
    final local = utc.add(Duration(minutes: offsetMinutes));
    return DateTime.utc(local.year, local.month, local.day);
  }
}
