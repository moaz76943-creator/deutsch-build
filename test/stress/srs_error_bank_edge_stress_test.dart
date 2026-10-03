import 'dart:math' as math;

import 'package:deutsch_bilarabi/core/srs.dart';
import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stress_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LearnerRepository> repository() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final prefs = await PreferencesService.instance();
    final persistence = LearnerPersistence(
      prefs,
      LearnerRepository.key,
      LearnerRepository.legacyFavoriteKey,
    );
    return LearnerRepository(prefs, persistence: persistence);
  }

  test('SRS remains bounded and finite through a long adversarial review sequence', () {
    final start = DateTime.utc(2026, 1, 1);
    var card = ReviewCard(
      itemId: 'stress-srs',
      dueAt: start,
      difficulty: 2.5,
      stabilityDays: 3650,
    );

    for (var index = 0; index < 5000; index += 1) {
      final correct = index % 7 != 0;
      final hinted = index % 5 == 0;
      final now = start.add(Duration(minutes: index));
      card = Srs.update(
        card,
        correct: correct,
        hinted: hinted,
        now: now,
      );

      expect(card.intervalDays, inInclusiveRange(0, 3650));
      expect(card.stabilityDays.isFinite, isTrue);
      expect(card.stabilityDays, inInclusiveRange(.25, 3650));
      expect(card.difficulty.isFinite, isTrue);
      expect(card.difficulty, inInclusiveRange(.5, 2.5));
      expect(Srs.retrievability(card, now: now), inInclusiveRange(0.0, 1.0));
      expect(Srs.reviewPriority(card, now: now), inInclusiveRange(0.0, 2.0));
    }
  });

  test('deserialization neutralizes non-finite and absurd SRS numbers', () {
    final now = DateTime.now();
    final card = ReviewCard.fromJson(<String, dynamic>{
      'itemId': 'stress-numeric',
      'repetitions': -999999999,
      'intervalDays': 999999999,
      'lapses': 999999999,
      'successes': -500,
      'failures': 999999999,
      'difficulty': double.nan,
      'stabilityDays': double.infinity,
      'dueAt': '1900-01-01T00:00:00.000Z',
      'lastReviewedAt': '2999-01-01T00:00:00.000Z',
    });

    expect(card.repetitions, 0);
    expect(card.intervalDays, 3650);
    expect(card.lapses, 1000);
    expect(card.successes, 0);
    expect(card.failures, 10000);
    expect(card.difficulty.isFinite, isTrue);
    expect(card.difficulty, inInclusiveRange(.5, 2.5));
    expect(card.stabilityDays.isFinite, isTrue);
    expect(card.stabilityDays, inInclusiveRange(0.0, 3650));
    expect(card.dueAt.isAfter(now.subtract(const Duration(minutes: 1))), isTrue);
  });

  test('empty, oversized, and invalid-facet inputs stay bounded in the error bank', () async {
    final repo = await repository();
    const item = StressLearningContent(id: 'stress-edge-item');

    await repo.record(
      item: item,
      answer: '',
      correct: false,
      seconds: -1000000,
      hinted: false,
      at: DateTime.utc(2026, 1, 1),
    );

    final hugeAnswer = List<String>.filled(25000, 'x').join();
    await repo.record(
      item: item,
      answer: hugeAnswer,
      correct: true,
      seconds: 999999999,
      hinted: false,
      at: DateTime.utc(2026, 1, 2),
    );

    final beforeInvalidFacet = (await repo.reloadPersisted()).attempts.length;
    await repo.recordFacet(
      item: item,
      facetType: ReviewFacetType.spelling,
      variantKey: List<String>.filled(81, 'v').join(),
      answer: hugeAnswer,
      correct: false,
      seconds: 20,
      hinted: false,
      at: DateTime.utc(2026, 1, 3),
    );

    final state = await repo.reloadPersisted();
    expect(state.attempts, hasLength(beforeInvalidFacet));
    expect(state.attempts.first.answer, isEmpty);
    expect(state.attempts.first.seconds, 0);
    expect(state.attempts.last.answer.length, 1000);
    expect(state.attempts.last.seconds, 3600);
    expect(state.reviewCards.values.every((card) => card.facetKey.isValid), isTrue);
    expect(state.xp, inInclusiveRange(0, LearnerRepository.maxXp));
    expect(state.streak, inInclusiveRange(0, LearnerRepository.maxStreak));

    final invalidEmpty = ReviewFacetKey(
      conceptId: '',
      facetType: ReviewFacetType.spelling,
    );
    final invalidHugeVariant = ReviewFacetKey(
      conceptId: item.id,
      facetType: ReviewFacetType.spelling,
      variantKey: List<String>.filled(81, 'v').join(),
    );
    expect(invalidEmpty.isValid, isFalse);
    expect(invalidHugeVariant.isValid, isFalse);

    expect(math.max(0, state.attempts.length), state.attempts.length);
  });
}
