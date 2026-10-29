import 'preferences_service.dart';
import '../core/view_mode.dart';

class UiPreferences {
  static const viewModeKey = 'vocabulary_view_mode';
  static const dailyStudyTimeKey = 'daily_study_time_minutes';
  static const pomodoroTimerKey = 'pomodoro_timer_minutes';
  static const dailyNewCardsQuotaKey = 'daily_new_cards_quota';
  static const dailyReviewLimitKey = 'daily_review_limit';

  final PreferencesService _prefs;

  const UiPreferences(this._prefs);

  ViewMode? get viewMode {
    final stored = _prefs.getString(viewModeKey);
    if (stored == null || stored.isEmpty) return null;
    final normalized = stored.startsWith('ViewMode.')
        ? stored.substring('ViewMode.'.length)
        : stored;
    for (final mode in ViewMode.values) {
      if (mode.name == normalized) return mode;
    }
    return null;
  }

  Future<bool> setViewMode(ViewMode mode) {
    return _prefs.setString(viewModeKey, mode.name);
  }

  Future<bool> setDailyStudyProfile({
    required int minutes,
    required int newCardsQuota,
    required int reviewLimit,
  }) async {
    final results = await Future.wait<bool>([
      _prefs.setInt(dailyStudyTimeKey, minutes),
      _prefs.setInt(pomodoroTimerKey, minutes),
      _prefs.setInt(dailyNewCardsQuotaKey, newCardsQuota),
      _prefs.setInt(dailyReviewLimitKey, reviewLimit),
    ]);
    return results.every((value) => value);
  }
}
