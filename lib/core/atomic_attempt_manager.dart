import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Process-local idempotency record for learning attempts.
///
/// The in-memory set is the source of truth for the running process. Disk
/// persistence is best-effort and must not pin the caller: a SharedPreferences
/// channel that never completes (the Linux test store when no mock is
/// installed) used to leave [markAttemptProcessed] pending and stall the suite.
class AtomicAttemptManager {
  static const String _prefixProcessed = 'attempt_processed_';

  static final Set<String> _processed = <String>{};
  static Future<void> _tail = Future<void>.value();

  /// When true, tests may read and write the preferences store. Production
  /// always persists. Tests skip the platform store unless they opt in after
  /// [SharedPreferences.setMockInitialValues], so a missing channel handler
  /// cannot start a future that never completes.
  @visibleForTesting
  static bool debugAllowPlatform = false;

  @visibleForTesting
  static void debugReset() {
    _processed.clear();
    _tail = Future<void>.value();
    debugAllowPlatform = false;
  }

  /// Drops the process cache without touching the platform opt-in or disk.
  @visibleForTesting
  static void debugForgetProcessedMemory() {
    _processed.clear();
  }

  /// يتحقق مما إذا كانت المحاولة عولجت مسبقاً لمنع التكرار.
  static Future<bool> isAttemptProcessed(String attemptId) {
    if (_processed.contains(attemptId)) {
      return Future<bool>.value(true);
    }
    return _serialized(() async {
      if (_processed.contains(attemptId)) return true;
      final prefs = await _preferences();
      final stored = prefs?.getBool('$_prefixProcessed$attemptId') ?? false;
      if (stored) _processed.add(attemptId);
      return stored;
    });
  }

  /// تسجيل المحاولة كمعالجة بشكل ذري.
  static Future<void> markAttemptProcessed(String attemptId) {
    _processed.add(attemptId);
    return _serialized(() async {
      final prefs = await _preferences();
      if (prefs == null) return;
      await prefs.setBool('$_prefixProcessed$attemptId', true);
    });
  }

  static Future<T> _serialized<T>(Future<T> Function() body) {
    final gate = Completer<void>();
    final previous = _tail;
    _tail = gate.future;
    final result = previous.then((_) => body());
    result.whenComplete(() {
      if (!gate.isCompleted) gate.complete();
    });
    return result;
  }

  static bool get _platformAllowed {
    if (debugAllowPlatform) return true;
    return Platform.environment['FLUTTER_TEST'] != 'true';
  }

  static Future<SharedPreferences?> _preferences() async {
    if (!_platformAllowed) return null;
    try {
      final pending = SharedPreferences.getInstance();
      if (Platform.environment['FLUTTER_TEST'] == 'true') {
        return await pending.timeout(const Duration(milliseconds: 200));
      }
      return await pending;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
