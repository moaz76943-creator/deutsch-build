import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/sm18_hybrid_scheduler.dart';

void main() {
  group('Sm18HybridScheduler Unit Tests (N025)', () {
    const scheduler = Sm18HybridScheduler(desiredRetention: 0.90);

    test('Initial memory state behaves predictably', () {
      final initial = MemoryState.initial();
      expect(initial.stability, equals(1.0));
      expect(initial.reps, equals(0));
      expect(initial.nextIntervalDays, equals(1));
    });

    test('Consecutive good and instantMastery reviews exponentially expand interval', () {
      var state = MemoryState.initial();
      state = scheduler.review(previousState: state, rating: ReviewRating.good, daysElapsed: 1);
      expect(state.nextIntervalDays, greaterThan(1));
      expect(state.lapses, equals(0));

      final secondState = scheduler.review(
        previousState: state,
        rating: ReviewRating.instantMastery,
        daysElapsed: state.nextIntervalDays,
      );
      expect(secondState.nextIntervalDays, greaterThan(state.nextIntervalDays));
      expect(secondState.stability, greaterThan(state.stability));
    });

    test('Blackout lapse applies severe penalty and increases difficulty', () {
      var state = MemoryState(
        stability: 30.0,
        difficulty: 4.0,
        retrievability: 0.85,
        reps: 5,
        lapses: 0,
        nextIntervalDays: 30,
      );

      final failedState = scheduler.review(
        previousState: state,
        rating: ReviewRating.blackout,
        daysElapsed: 30,
      );

      expect(failedState.lapses, equals(1));
      expect(failedState.stability, lessThan(state.stability));
      expect(failedState.difficulty, greaterThan(state.difficulty));
    });

    test('Retrievability decays with elapsed days according to forgetting curve', () {
      final rDay0 = scheduler.estimateRetrievability(10.0, 0);
      final rDay10 = scheduler.estimateRetrievability(10.0, 10);
      final rDay50 = scheduler.estimateRetrievability(10.0, 50);

      expect(rDay0, equals(1.0));
      expect(rDay10, closeTo(0.90, 0.05));
      expect(rDay50, lessThan(rDay10));
    });
  });
}
