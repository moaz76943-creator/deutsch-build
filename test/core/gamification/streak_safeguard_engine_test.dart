import 'package:test/test.dart';
import 'package:deutsch_build/src/core/gamification/streak_safeguard_engine.dart';

void main() {
  group('StreakSafeguardEngine Tests', () {
    const engine = StreakSafeguardEngine();

    test('Increments streak on consecutive day study', () {
      final initial = StreakState(
        streakDays: 5,
        lastStudyDate: DateTime(2026, 10, 20),
        availableFreezes: 2,
      );

      final next = engine.evaluateStreak(
        currentState: initial,
        currentDate: DateTime(2026, 10, 21),
      );

      expect(next.streakDays, equals(6));
      expect(next.availableFreezes, equals(2));
    });

    test('Consumes freeze to preserve streak on single day absence', () {
      final initial = StreakState(
        streakDays: 10,
        lastStudyDate: DateTime(2026, 10, 20),
        availableFreezes: 1,
      );

      // Missed Oct 21, returned Oct 22
      final next = engine.evaluateStreak(
        currentState: initial,
        currentDate: DateTime(2026, 10, 22),
      );

      expect(next.streakDays, equals(10)); // Preserved!
      expect(next.availableFreezes, equals(0)); // Consumed
      expect(next.isProtectedToday, isTrue);
    });
  });
}
