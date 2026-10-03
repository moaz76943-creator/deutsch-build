import 'package:deutsch_bilarabi/features/learning/domain/adaptive_error_bank.dart';
import 'package:deutsch_bilarabi/features/learning/domain/learning_entities.dart';
import 'package:deutsch_bilarabi/features/learning/domain/srs_engine.dart';
import 'package:deutsch_bilarabi/models/mistake.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('learning domain SRS surface', () {
    test('good review schedules the first repetition exactly one day later', () {
      final now = DateTime.utc(2026, 10, 3, 12);
      final state = SrsItemState(
        intervalDays: 0,
        repetitions: 0,
        dueDate: now,
        state: CardState.newCard,
      );

      final result = SrsEngine().calculateNextState(state, Rating.good, now);

      expect(result.intervalDays, 1);
      expect(result.repetitions, 1);
      expect(result.easeFactor, 2.5);
      expect(result.dueDate, DateTime.utc(2026, 10, 4, 12));
    });

    test('ease factor never falls below the canonical 1.3 floor', () {
      final now = DateTime.utc(2026, 10, 3, 12);
      final state = SrsItemState(
        intervalDays: 6,
        repetitions: 2,
        easeFactor: 1.35,
        dueDate: now,
        state: CardState.reviewing,
      );

      final result = SrsEngine().calculateNextState(state, Rating.again, now);

      expect(result.easeFactor, 1.3);
      expect(result.intervalDays, 1);
      expect(result.repetitions, 0);
    });
  });

  group('AdaptiveErrorBank', () {
    const bank = AdaptiveErrorBank();
    final now = DateTime.utc(2026, 10, 3, 12);

    MistakeRecord mistake({
      required String itemId,
      required MistakeCategory category,
      required int severity,
      required int errors,
      required int attempts,
      required double failureRate,
      required double recentFailureRate,
    }) =>
        MistakeRecord(
          itemId: itemId,
          category: category,
          source: MistakeSource.practice,
          errorCount: errors,
          attemptCount: attempts,
          correctiveStreak: 0,
          lastSeenAt: now,
          severity: severity,
          normalizedKey: '${category.name}:$itemId',
          failureRate: failureRate,
          recentFailureRate: recentFailureRate,
        );

    test('classifies vocabulary, grammar, and conjugation distinctly', () {
      final vocabulary = mistake(
        itemId: 'word-1',
        category: MistakeCategory.vocabulary,
        severity: 30,
        errors: 1,
        attempts: 3,
        failureRate: .33,
        recentFailureRate: .33,
      );
      final grammar = mistake(
        itemId: 'grammar-1',
        category: MistakeCategory.grammar,
        severity: 30,
        errors: 1,
        attempts: 3,
        failureRate: .33,
        recentFailureRate: .33,
      );

      expect(bank.classify(vocabulary), AdaptiveErrorType.vocabulary);
      expect(bank.classify(grammar), AdaptiveErrorType.grammar);
      expect(
        bank.classify(vocabulary, skill: 'verb_conjugation'),
        AdaptiveErrorType.conjugation,
      );
    });

    test('more severe repeated errors are rescheduled sooner', () {
      final state = SrsItemState(
        intervalDays: 20,
        repetitions: 4,
        dueDate: now,
        state: CardState.reviewing,
      );
      final mild = mistake(
        itemId: 'mild',
        category: MistakeCategory.vocabulary,
        severity: 15,
        errors: 1,
        attempts: 5,
        failureRate: .20,
        recentFailureRate: .20,
      );
      final severe = mistake(
        itemId: 'severe',
        category: MistakeCategory.vocabulary,
        severity: 95,
        errors: 5,
        attempts: 6,
        failureRate: .83,
        recentFailureRate: .83,
      );

      final mildDays = bank.acceleratedIntervalDays(state, mild, now: now);
      final severeDays = bank.acceleratedIntervalDays(state, severe, now: now);

      expect(severeDays, lessThan(mildDays));
      expect(severeDays, greaterThanOrEqualTo(1));
      expect(mildDays, lessThanOrEqualTo(state.intervalDays));
    });

    test('priority ordering is deterministic and highest urgency comes first', () {
      final state = SrsItemState(
        intervalDays: 12,
        repetitions: 3,
        dueDate: now,
        state: CardState.reviewing,
      );
      final low = mistake(
        itemId: 'low',
        category: MistakeCategory.vocabulary,
        severity: 10,
        errors: 1,
        attempts: 5,
        failureRate: .20,
        recentFailureRate: .20,
      );
      final high = mistake(
        itemId: 'high',
        category: MistakeCategory.grammar,
        severity: 90,
        errors: 4,
        attempts: 5,
        failureRate: .80,
        recentFailureRate: .80,
      );

      final ranked = bank.prioritize(
        [low, high],
        {'low': state, 'high': state},
        reviewedAtUtc: now,
      );

      expect(ranked.map((x) => x.itemId).toList(), ['high', 'low']);
      expect(ranked.first.priority, greaterThan(ranked.last.priority));
      expect(ranked.first.nextReviewAt.isUtc, isTrue);
    });

    test('rejects non-UTC review timestamps', () {
      final state = SrsItemState(
        intervalDays: 10,
        repetitions: 3,
        dueDate: now,
        state: CardState.reviewing,
      );
      final record = mistake(
        itemId: 'word-1',
        category: MistakeCategory.vocabulary,
        severity: 50,
        errors: 2,
        attempts: 4,
        failureRate: .50,
        recentFailureRate: .50,
      );

      expect(
        () => bank.signalFor(
          record,
          state,
          reviewedAtUtc: DateTime(2026, 10, 3, 12),
        ),
        throwsArgumentError,
      );
    });
  });

  group('immutable learning entities', () {
    test('vocabulary entity exposes the canonical German article', () {
      const entry = VocabularyEntity(
        id: 'haus',
        german: 'Haus',
        arabic: 'منزل',
        gender: GermanGender.neuter,
        exampleGerman: 'Das Haus ist groß.',
        exampleArabic: 'المنزل كبير.',
      );

      expect(entry.article, 'das');
      expect(entry.german, 'Haus');
      expect(entry.arabic, 'منزل');
    });

    test('grammar entity keeps rule and example data immutable', () {
      const rule = GrammarEntity(
        id: 'verb-second-position',
        title: 'Verb position',
        explanationArabic: 'يأتي الفعل المصرف في الموقع الثاني.',
        exampleGerman: 'Heute lerne ich Deutsch.',
        exampleArabic: 'اليوم أتعلم الألمانية.',
      );

      expect(rule.title, 'Verb position');
      expect(rule.exampleGerman, 'Heute lerne ich Deutsch.');
    });
  });
}
