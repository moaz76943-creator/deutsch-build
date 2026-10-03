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
  });

  group('AdaptiveSrsAgent', () {
    const agent = AdaptiveSrsAgent();
    final now = DateTime.utc(2026, 10, 3, 12);

    SrsItemState state(
      CardState cardState,
      int interval, {
      DateTime? due,
    }) =>
        SrsItemState(
          intervalDays: interval,
          repetitions: 3,
          dueDate: due ?? now,
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

    test('uses complete attempt evidence for retention and due review priority', () {
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
        totalAttempts: 102,
        correctAttempts: 101,
        curriculumLevelByItem: const {
          'low': 'A1',
          'high': 'A1',
          'mastered': 'A1',
          'unseen': 'A1',
        },
        masteredItemIds: const {'mastered'},
        nowUtc: now,
        reviewLimit: 2,
        displayLabelByItem: const {
          'low': 'das Haus',
          'high': 'der Bahnhof',
        },
      );

      expect(result.retentionRate, closeTo(101 / 102, .0001));
      expect(result.masteredWords, 1);
      expect(result.currentStreakDays, 2);
      expect(result.dailyReview, hasLength(2));
      expect(result.dailyReview.first.itemId, 'high');
      expect(result.dailyReview.first.displayLabel, 'der Bahnhof');
      expect(result.curriculumProgress, .25);
      expect(result.progressBand, 'A1');
      expect(result.masteryIndex, inInclusiveRange(0.0, 1.0));
    });

    test('does not schedule a struggling card before its canonical due date', () {
      final future = mistake(
        id: 'future',
        errors: 3,
        attempts: 4,
        severity: 95,
        failureRate: .75,
      );

      final result = agent.analyze(
        activityTimesUtc: const <DateTime>[],
        mistakes: [future],
        states: {
          'future': state(
            CardState.reviewing,
            10,
            due: now.add(const Duration(days: 2)),
          ),
        },
        totalAttempts: 4,
        correctAttempts: 1,
        curriculumLevelByItem: const {'future': 'A1'},
        masteredItemIds: const <String>{},
        nowUtc: now,
      );

      expect(result.dailyReview, isEmpty);
    });

    test('curriculum denominator prevents one mastered card from implying B1', () {
      final result = agent.analyze(
        activityTimesUtc: const <DateTime>[],
        mistakes: const <MistakeRecord>[],
        states: {
          'one': state(CardState.mastered, 30),
        },
        totalAttempts: 1,
        correctAttempts: 1,
        curriculumLevelByItem: const {
          'one': 'A1',
          'two': 'A1',
          'three': 'A2',
          'four': 'B1',
        },
        masteredItemIds: const {'one'},
        nowUtc: now,
      );

      expect(result.curriculumProgress, .25);
      expect(result.progressBand, 'A1');
    });

    test('returns safe empty analytics when there is no learner evidence', () {
      final result = agent.analyze(
        activityTimesUtc: const <DateTime>[],
        mistakes: const <MistakeRecord>[],
        states: const <String, SrsItemState>{},
        totalAttempts: 0,
        correctAttempts: 0,
        curriculumLevelByItem: const <String, String>{},
        masteredItemIds: const <String>{},
        nowUtc: now,
      );

      expect(result.retentionRate, 0.0);
      expect(result.masteryIndex, 0.0);
      expect(result.curriculumProgress, 0.0);
      expect(result.masteredWords, 0);
      expect(result.currentStreakDays, 0);
      expect(result.progressBand, 'A1');
      expect(result.dailyReview, isEmpty);
    });

    test('rejects invalid attempt totals', () {
      expect(
        () => agent.analyze(
          activityTimesUtc: const <DateTime>[],
          mistakes: const <MistakeRecord>[],
          states: const <String, SrsItemState>{},
          totalAttempts: 2,
          correctAttempts: 3,
          curriculumLevelByItem: const <String, String>{},
          masteredItemIds: const <String>{},
          nowUtc: now,
        ),
        throwsArgumentError,
      );
    });
  });
}
