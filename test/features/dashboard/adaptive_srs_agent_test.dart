import 'package:deutsch_bilarabi/core/srs/srs_models.dart';
import 'package:deutsch_bilarabi/domain/adaptive_agent/adaptive_srs_agent.dart';
import 'package:deutsch_bilarabi/domain/adaptive_agent/daily_streak_engine.dart';
import 'package:deutsch_bilarabi/models/mistake.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyStreakEngine', () {
    const engine = DailyStreakEngine();

    test('counts unique consecutive local study days ending today', () {
      final now = DateTime.utc(2026, 10, 3, 20);
      final streak = engine.currentStreak(
        [
          DateTime.utc(2026, 10, 1, 21),
          DateTime.utc(2026, 10, 2, 8),
          DateTime.utc(2026, 10, 2, 19),
          DateTime.utc(2026, 10, 3, 7),
        ],
        nowUtc: now,
        timezoneOffsetMinutes: 180,
      );

      expect(streak, 3);
    });

    test('keeps yesterday streak before the learner studies today', () {
      final now = DateTime.utc(2026, 10, 3, 8);
      final streak = engine.currentStreak(
        [
          DateTime.utc(2026, 10, 1, 10),
          DateTime.utc(2026, 10, 2, 10),
        ],
        nowUtc: now,
      );

      expect(streak, 2);
    });

    test('returns zero when latest activity is older than yesterday', () {
      final streak = engine.currentStreak(
        [DateTime.utc(2026, 9, 30, 10)],
        nowUtc: DateTime.utc(2026, 10, 3, 10),
      );

      expect(streak, 0);
    });

    test('rejects a non UTC now timestamp', () {
      expect(
        () => engine.currentStreak(
          const <DateTime>[],
          nowUtc: DateTime(2026, 10, 3),
        ),
        throwsArgumentError,
      );
    });
  });

  group('AdaptiveSrsAgent', () {
    const agent = AdaptiveSrsAgent();
    final now = DateTime.utc(2026, 10, 3, 12);

    SrsItemState state(CardState cardState, int interval) => SrsItemState(
          intervalDays: interval,
          repetitions: 3,
          dueDate: now,
          state: cardState,
        );

    MistakeRecord mistake({
      required String id,
      required int errors,
      required int attempts,
      required int severity,
      required double failureRate,
    }) =>
        MistakeRecord(
          itemId: id,
          category: MistakeCategory.vocabulary,
          source: MistakeSource.practice,
          errorCount: errors,
          attemptCount: attempts,
          correctiveStreak: 0,
          lastSeenAt: now,
          severity: severity,
          normalizedKey: 'vocabulary:$id',
          failureRate: failureRate,
          recentFailureRate: failureRate,
        );

    test('derives retention, mastered count and deterministic review priority', () {
      final low = mistake(
        id: 'low',
        errors: 1,
        attempts: 5,
        severity: 20,
        failureRate: .2,
      );
      final high = mistake(
        id: 'high',
        errors: 4,
        attempts: 5,
        severity: 95,
        failureRate: .8,
      );

      final result = agent.analyze(
        activityTimesUtc: [
          DateTime.utc(2026, 10, 2, 9),
          DateTime.utc(2026, 10, 3, 9),
        ],
        mistakes: [low, high],
        states: {
          'low': state(CardState.reviewing, 20),
          'high': state(CardState.learning, 20),
          'mastered': state(CardState.mastered, 30),
        },
        nowUtc: now,
        reviewLimit: 2,
        displayLabelByItem: const {
          'low': 'das Haus',
          'high': 'der Bahnhof',
        },
      );

      expect(result.retentionRate, closeTo(.5, .0001));
      expect(result.masteredWords, 1);
      expect(result.currentStreakDays, 2);
      expect(result.dailyReview, hasLength(2));
      expect(result.dailyReview.first.itemId, 'high');
      expect(result.dailyReview.first.displayLabel, 'der Bahnhof');
      expect(
        result.dailyReview.first.reviewIntervalDays,
        lessThan(result.dailyReview.last.reviewIntervalDays),
      );
      expect(result.masteryIndex, inInclusiveRange(0.0, 1.0));
    });

    test('limits the daily queue without mutating the canonical state map', () {
      final states = {
        'a': state(CardState.reviewing, 8),
        'b': state(CardState.reviewing, 8),
      };
      final result = agent.analyze(
        activityTimesUtc: const <DateTime>[],
        mistakes: [
          mistake(
            id: 'a',
            errors: 2,
            attempts: 3,
            severity: 80,
            failureRate: .66,
          ),
          mistake(
            id: 'b',
            errors: 1,
            attempts: 3,
            severity: 40,
            failureRate: .33,
          ),
        ],
        states: states,
        nowUtc: now,
        reviewLimit: 1,
      );

      expect(result.dailyReview, hasLength(1));
      expect(states['a']!.intervalDays, 8);
      expect(states['b']!.intervalDays, 8);
    });

    test('returns safe empty analytics when there is no tracked learning data', () {
      final result = agent.analyze(
        activityTimesUtc: const <DateTime>[],
        mistakes: const <MistakeRecord>[],
        states: const <String, SrsItemState>{},
        nowUtc: now,
      );

      expect(result.retentionRate, 1.0);
      expect(result.masteryIndex, 0.0);
      expect(result.masteredWords, 0);
      expect(result.currentStreakDays, 0);
      expect(result.progressBand, 'A1');
      expect(result.dailyReview, isEmpty);
    });

    test('rejects a negative review limit', () {
      expect(
        () => agent.analyze(
          activityTimesUtc: const <DateTime>[],
          mistakes: const <MistakeRecord>[],
          states: const <String, SrsItemState>{},
          nowUtc: now,
          reviewLimit: -1,
        ),
        throwsArgumentError,
      );
    });
  });
}
