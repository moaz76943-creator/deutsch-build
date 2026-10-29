import 'package:shared_preferences/shared_preferences.dart';

/// CrashLoopGuard: Protects against repeated crashes that could indicate
/// tampering, data corruption, or unstable state. Resets after 5 minutes.
///
/// Improves resilience and security by detecting potential modding or corruption
/// attempts that cause crash loops.
class CrashLoopGuard {
  static const String _keyCrashCount = 'deutsch_crash_count_v1';
  static const String _keyLastCrash = 'deutsch_last_crash_v1';
  static const int _maxCrashes = 3;
  static const Duration _resetDuration = Duration(minutes: 5);

  final SharedPreferences _prefs;

  CrashLoopGuard(this._prefs);

  Future<void> recordFailure() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCrash = _prefs.getInt(_keyLastCrash) ?? 0;
    int crashCount = _prefs.getInt(_keyCrashCount) ?? 0;

    if (now - lastCrash < _resetDuration.inMilliseconds) {
      crashCount++;
    } else {
      crashCount = 1;
    }

    await _prefs.setInt(_keyLastCrash, now);
    await _prefs.setInt(_keyCrashCount, crashCount);
  }

  Future<void> recordSuccess() async {
    await _prefs.remove(_keyCrashCount);
    await _prefs.remove(_keyLastCrash);
  }

  bool isCrashLoopDetected() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCrash = _prefs.getInt(_keyLastCrash) ?? 0;
    final crashCount = _prefs.getInt(_keyCrashCount) ?? 0;

    if (now - lastCrash > _resetDuration.inMilliseconds) {
      return false;
    }

    return crashCount >= _maxCrashes;
  }
}
