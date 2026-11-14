import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/gamification/endurance_survival_engine.dart';

void main() {
  group('EnduranceSurvivalEngine Tests', () {
    const engine = EnduranceSurvivalEngine(initialLives: 3);

    test('Initializes with 3 lives and tier 1', () {
      final session = engine.startSession();
      expect(session.remainingLives, equals(3));
      expect(session.currentDifficultyTier, equals(1));
      expect(session.isGameOver, isFalse);
    });

    test('Scales difficulty tier after consecutive correct answers', () {
      var state = engine.startSession();

      for (int i = 0; i < 5; i++) {
        state = engine.submitAnswer(state: state, isCorrect: true);
      }

      expect(state.consecutiveCorrect, equals(5));
      expect(state.currentDifficultyTier, equals(2)); // Advanced to Tier 2!
      expect(state.remainingLives, equals(3));
    });

    test('Deducts life on error and triggers game over after 3 mistakes', () {
      var state = engine.startSession();

      state = engine.submitAnswer(state: state, isCorrect: false); // Mistake 1
      expect(state.remainingLives, equals(2));
      expect(state.isGameOver, isFalse);

      state = engine.submitAnswer(state: state, isCorrect: false); // Mistake 2
      expect(state.remainingLives, equals(1));

      state = engine.submitAnswer(state: state, isCorrect: false); // Mistake 3
      expect(state.remainingLives, equals(0));
      expect(state.isGameOver, isTrue);
    });
  });
}
