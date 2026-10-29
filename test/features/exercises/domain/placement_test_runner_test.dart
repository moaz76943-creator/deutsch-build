import 'package:test/test.dart';
import 'package:deutsch_build/src/features/exercises/domain/placement_test_runner.dart';

void main() {
  group('PlacementTestRunner Adaptive IRT Tests', () {
    test('Selects next item closest to prior theta', () {
      final runner = PlacementTestRunner(itemPool: PlacementTestRunner.defaultBank);
      final firstItem = runner.selectNextItem();
      expect(firstItem, isNotNull);
      // Closest to initial theta (0.0) is B1 (0.2)
      expect(firstItem!.targetLevel, equals(CefrLevel.B1));
    });

    test('Increases theta on correct answers and classifies higher level', () {
      final runner = PlacementTestRunner(itemPool: PlacementTestRunner.defaultBank);

      for (int i = 0; i < 5; i++) {
        final item = runner.selectNextItem();
        if (item == null) break;
        runner.submitAnswer(item, item.correctOption); // All correct
      }

      expect(runner.currentTheta, greaterThan(0.0));
      final result = runner.finalizeResult();
      expect(result.correctAnswers, greaterThanOrEqualTo(4));
    });

    test('Decreases theta on incorrect answers and classifies A1/A2', () {
      final runner = PlacementTestRunner(itemPool: PlacementTestRunner.defaultBank);

      for (int i = 0; i < 5; i++) {
        final item = runner.selectNextItem();
        if (item == null) break;
        runner.submitAnswer(item, 'WRONG_ANSWER'); // All wrong
      }

      expect(runner.currentTheta, lessThan(0.0));
      final result = runner.finalizeResult();
      expect([CefrLevel.A1, CefrLevel.A2], contains(result.determinedLevel));
    });
  });
}
