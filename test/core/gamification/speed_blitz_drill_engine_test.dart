import 'package:test/test.dart';
import 'package:deutsch_build/src/core/gamification/speed_blitz_drill_engine.dart';

void main() {
  group('SpeedBlitzDrillEngine Tests', () {
    late SpeedBlitzDrillEngine engine;

    setUp(() {
      engine = SpeedBlitzDrillEngine();
    });

    test('Awards multiplied points for quick consecutive answers', () {
      // First quick answer (took 1 sec out of 5)
      final eval1 = engine.submitAnswer(
        isCorrect: true,
        timeTaken: const Duration(seconds: 1),
      );

      expect(eval1.isCorrect, isTrue);
      expect(eval1.consecutiveCorrectCombo, equals(1));
      expect(eval1.earnedScore, greaterThan(15));

      // Second quick answer builds combo
      final eval2 = engine.submitAnswer(
        isCorrect: true,
        timeTaken: const Duration(seconds: 1),
      );

      expect(eval2.consecutiveCorrectCombo, equals(2));
      expect(eval2.activeMultiplier, greaterThan(eval1.activeMultiplier));
    });

    test('Resets combo to zero on timeout or incorrect answer', () {
      engine.submitAnswer(isCorrect: true, timeTaken: const Duration(seconds: 1));
      expect(engine.currentCombo, equals(1));

      // Timeout (took 6 seconds > 5 limit)
      final fail = engine.submitAnswer(isCorrect: true, timeTaken: const Duration(seconds: 6));
      expect(fail.isCorrect, isFalse);
      expect(engine.currentCombo, equals(0));
    });
  });
}
