import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/resilience/crash_loop_guard.dart'; // We import it from here, as the code is the same. The prompt refers to main.dart which has a duplicate.

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CrashLoopGuard', () {
    test('initial state does not detect a crash loop', () async {
      final prefs = await SharedPreferences.getInstance();
      final guard = CrashLoopGuard(prefs);

      expect(guard.isCrashLoopDetected(), isFalse);
    });

    test('records a single failure without triggering crash loop', () async {
      final prefs = await SharedPreferences.getInstance();
      final guard = CrashLoopGuard(prefs);

      await guard.recordFailure();

      expect(guard.isCrashLoopDetected(), isFalse);
      expect(prefs.getInt('deutsch_crash_count_v1'), 1);
    });

    test('detects crash loop after multiple rapid failures', () async {
      final prefs = await SharedPreferences.getInstance();
      final guard = CrashLoopGuard(prefs);

      // Simulate 3 rapid crashes
      await guard.recordFailure();
      await guard.recordFailure();
      await guard.recordFailure();

      expect(guard.isCrashLoopDetected(), isTrue);
      expect(prefs.getInt('deutsch_crash_count_v1'), 3);
    });

    test('resets crash count after the reset duration has passed', () async {
      final prefs = await SharedPreferences.getInstance();
      final guard = CrashLoopGuard(prefs);

      // Simulate 2 rapid crashes
      await guard.recordFailure();
      await guard.recordFailure();
      expect(prefs.getInt('deutsch_crash_count_v1'), 2);

      // Manually modify the last crash time to simulate a long delay
      final pastTime = DateTime.now().subtract(const Duration(minutes: 6)).millisecondsSinceEpoch;
      await prefs.setInt('deutsch_last_crash_v1', pastTime);

      // Simulate another crash
      await guard.recordFailure();

      // The count should reset to 1 because the reset duration elapsed
      expect(prefs.getInt('deutsch_crash_count_v1'), 1);
      expect(guard.isCrashLoopDetected(), isFalse);
    });

    test('recordSuccess clears crash tracking keys', () async {
      final prefs = await SharedPreferences.getInstance();
      final guard = CrashLoopGuard(prefs);

      // Record a failure
      await guard.recordFailure();
      expect(prefs.getInt('deutsch_crash_count_v1'), 1);
      expect(prefs.getInt('deutsch_last_crash_v1'), isNotNull);

      // Record success
      await guard.recordSuccess();

      // Ensure keys are removed
      expect(prefs.getInt('deutsch_crash_count_v1'), isNull);
      expect(prefs.getInt('deutsch_last_crash_v1'), isNull);
      expect(guard.isCrashLoopDetected(), isFalse);
    });
  });
}
