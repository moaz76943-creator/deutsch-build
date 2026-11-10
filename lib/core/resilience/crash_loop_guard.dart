import '../persistence/local_persistence_port.dart';

/// CrashLoopGuard: Protects against repeated crashes that could indicate
/// tampering, data corruption, or unstable state. Resets after 5 minutes.
///
/// Improves resilience and security by detecting potential modding or corruption
/// attempts that cause crash loops.
///
/// Now depends only on LocalPersistencePort (not SharedPreferences directly)
/// for compliance with architecture rules, better testability, and centralized
/// control over persistent data (reduces leak/tampering surface).
class CrashLoopGuard {
  static const String _keyCrashCount = 'deutsch_crash_count_v1';
  static const String _keyLastCrash = 'deutsch_last_crash_v1';
  static const int _maxCrashes = 3;
  static const Duration _resetDuration = Duration(minutes: 5);

  final LocalPersistencePort _persistence;

  CrashLoopGuard(this._persistence);

  Future<void> recordFailure() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCrash = await _persistence.getInt(_keyLastCrash) ?? 0;
    int crashCount = await _persistence.getInt(_keyCrashCount) ?? 0;

    if (now - lastCrash < _resetDuration.inMilliseconds) {
      crashCount++;
    } else {
      crashCount = 1;
    }

    await _persistence.setInt(_keyLastCrash, now);
    await _persistence.setInt(_keyCrashCount, crashCount);
  }

  Future<void> recordSuccess() async {
    await _persistence.remove(_keyCrashCount);
    await _persistence.remove(_keyLastCrash);
  }

  Future<bool> isCrashLoopDetected() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCrash = await _persistence.getInt(_keyLastCrash) ?? 0;
    final crashCount = await _persistence.getInt(_keyCrashCount) ?? 0;

    if (now - lastCrash > _resetDuration.inMilliseconds) {
      return false;
    }

    return crashCount >= _maxCrashes;
  }
}
