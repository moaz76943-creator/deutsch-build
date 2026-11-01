import 'package:test/test.dart';
import 'package:deutsch_build/src/core/krashen/fsrs_v5_spaced_repetition_engine.dart';

void main() {
  group('FsrsV5SpacedRepetitionEngine Suite', () {
    const engine = FsrsV5SpacedRepetitionEngine(requestRetention: 0.90);

    test('Initializes new card and computes positive stability and future due date', () {
      final now = DateTime(2026, 11, 1).millisecondsSinceEpoch;
      final state = engine.initializeNewItem('word_ar_kitab', FsrsRating.good, now);

      expect(state.itemId, equals('word_ar_kitab'));
      expect(state.stability, closeTo(3.12, 1e-2));
      expect(state.state, equals(CardState.review));
      expect(state.reps, equals(1));
      expect(state.dueEpochMs, greaterThan(now));
    });

    test('Successful recall increases stability and schedules interval further in future', () {
      final t0 = DateTime(2026, 11, 1).millisecondsSinceEpoch;
      var state = engine.initializeNewItem('word_tr_ev', FsrsRating.good, t0);
      final initialStability = state.stability;

      // Review 3 days later with 'good' recall
      final t1 = t0 + (3 * 86400000);
      state = engine.reviewItem(state, FsrsRating.good, t1);

      expect(state.stability, greaterThan(initialStability));
      expect(state.reps, equals(2));
      expect(state.lapses, equals(0));
    });

    test('Lapse (rating: again) drops stability and marks item as relearning', () {
      final t0 = DateTime(2026, 11, 1).millisecondsSinceEpoch;
      var state = engine.initializeNewItem('word_id_buku', FsrsRating.good, t0);

      final t1 = t0 + (5 * 86400000);
      state = engine.reviewItem(state, FsrsRating.again, t1);

      expect(state.lapses, equals(1));
      expect(state.state, equals(CardState.relearning));
      expect(state.stability, lessThan(1.0));
    });
  });
}
