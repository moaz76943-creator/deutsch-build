import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/srs/srs_models.dart';
import 'package:deutsch_bilarabi/core/srs/srs_engine.dart';

void main() {
  group('SrsEngine', () {
    late SrsEngine engine;
    late DateTime now;

    setUp(() {
      engine = SrsEngine();
      now = DateTime.utc(2023, 1, 1, 12, 0, 0);
    });

    test('Throws ArgumentError if reviewTimeUtc is not UTC', () {
      final initialState = SrsItemState(
        intervalDays: 0,
        repetitions: 0,
        dueDate: now,
        state: CardState.newCard,
      );

      expect(
        () => engine.calculateNextState(
          initialState,
          Rating.good,
          DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('Sequence transitions: new card -> good -> good -> easy', () {
      // 1. New Card
      final initialState = SrsItemState(
        intervalDays: 0,
        repetitions: 0,
        dueDate: now,
        state: CardState.newCard,
      );

      // 2. First review: Good
      final state1 = engine.calculateNextState(initialState, Rating.good, now);
      expect(state1.repetitions, 1);
      expect(state1.intervalDays, 1);
      expect(state1.easeFactor, 2.5);
      expect(state1.dueDate, now.add(Duration(days: 1)));
      expect(state1.state, CardState.reviewing);

      // 3. Second review: Good (assume 1 day passed)
      final reviewTime2 = now.add(Duration(days: 1));
      final state2 = engine.calculateNextState(
        state1,
        Rating.good,
        reviewTime2,
      );
      expect(state2.repetitions, 2);
      expect(state2.intervalDays, 6);
      expect(state2.easeFactor, 2.5);
      expect(state2.dueDate, reviewTime2.add(Duration(days: 6)));
      expect(state2.state, CardState.reviewing);

      // 4. Third review: Easy (assume 6 days passed)
      final reviewTime3 = reviewTime2.add(Duration(days: 6));
      final state3 = engine.calculateNextState(
        state2,
        Rating.easy,
        reviewTime3,
      );
      expect(state3.repetitions, 3);
      // Interval = 6 * 2.5 * 1.3 = 19.5 -> rounded = 20
      expect(state3.intervalDays, 20);
      expect(state3.easeFactor, 2.65); // 2.5 + 0.15
      expect(state3.dueDate, reviewTime3.add(Duration(days: 20)));
      expect(state3.state, CardState.mastered);
    });

    test('Penalty on again rating', () {
      final initialState = SrsItemState(
        intervalDays: 6,
        repetitions: 2,
        easeFactor: 2.5,
        dueDate: now,
        state: CardState.reviewing,
      );

      final stateAfterAgain = engine.calculateNextState(
        initialState,
        Rating.again,
        now,
      );

      expect(stateAfterAgain.repetitions, 0);
      expect(stateAfterAgain.intervalDays, 1);
      expect(stateAfterAgain.easeFactor, 2.3); // 2.5 - 0.20
      expect(stateAfterAgain.dueDate, now.add(Duration(days: 1)));
      expect(stateAfterAgain.state, CardState.learning);
    });

    test(
      'Boundary condition for easeFactor minimum threshold (floor at 1.3)',
      () {
        final initialState = SrsItemState(
          intervalDays: 1,
          repetitions: 1,
          easeFactor: 1.4, // close to min
          dueDate: now,
          state: CardState.reviewing,
        );

        // Rating again decreases ease factor by 0.20, so 1.4 - 0.20 = 1.2. Should floor to 1.3.
        final stateAfterAgain = engine.calculateNextState(
          initialState,
          Rating.again,
          now,
        );

        expect(stateAfterAgain.easeFactor, 1.3);
      },
    );

    test(
      'Hard rating slightly increases interval and penalizes ease factor',
      () {
        final initialState = SrsItemState(
          intervalDays: 10,
          repetitions: 3,
          easeFactor: 2.5,
          dueDate: now,
          state: CardState.reviewing,
        );

        final stateAfterHard = engine.calculateNextState(
          initialState,
          Rating.hard,
          now,
        );

        expect(stateAfterHard.repetitions, 4);
        expect(stateAfterHard.intervalDays, 12); // 10 * 1.2 = 12
        expect(stateAfterHard.easeFactor, 2.35); // 2.5 - 0.15
        expect(stateAfterHard.dueDate, now.add(Duration(days: 12)));
        expect(stateAfterHard.state, CardState.reviewing);
      },
    );
  });
}
