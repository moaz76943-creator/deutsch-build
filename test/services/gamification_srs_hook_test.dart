import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/core/srs_scheduler.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_review_sink.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';

final class _Sink implements GamificationReviewSink {
  final List<GamificationReviewEvent> events = <GamificationReviewEvent>[];
  bool cleared = false;

  @override
  Future<void> recordReview(GamificationReviewEvent event) async {
    events.add(event);
  }

  @override
  Future<void> clearGamification() async {
    cleared = true;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Phase 11 facet review emits scheduler-owned XP reward', () async {
    final prefs = await PreferencesService.instance();
    final sink = _Sink();
    final repo = LearnerRepository(
      prefs,
      persistence: LearnerPersistence(
        prefs,
        'phase16_state',
        'phase16_favorites',
      ),
      gamificationReviewSink: sink,
    );
    const item = ContentItem(
      id: 'w0044',
      german: 'machen',
      arabic: 'يفعل',
      sentence: 'Ich mache die Hausaufgabe.',
      sentenceAr: 'أؤدي الواجب.',
      topic: 'daily',
      skill: 'recall',
    );
    final at = DateTime.utc(2026, 10, 2, 8);

    await repo.recordFacet(
      item: item,
      facetType: ReviewFacetType.listening,
      answer: 'machen',
      correct: true,
      seconds: 5,
      hinted: true,
      at: at,
    );

    expect(sink.events, hasLength(1));
    expect(sink.events.single.facetType, ReviewFacetType.listening);
    expect(
      sink.events.single.requestedXp,
      unifiedSrsScheduler.xpRewardForReview(correct: true, hinted: true),
    );
    expect(sink.events.single.requestedXp, 6);
  });

  test('legacy meaning review also emits one gamification event', () async {
    final prefs = await PreferencesService.instance();
    final sink = _Sink();
    final repo = LearnerRepository(
      prefs,
      persistence: LearnerPersistence(
        prefs,
        'phase16_meaning',
        'phase16_meaning_favorites',
      ),
      gamificationReviewSink: sink,
    );
    const item = ContentItem(
      id: 'w0044',
      german: 'machen',
      arabic: 'يفعل',
      sentence: 'Ich mache die Hausaufgabe.',
      sentenceAr: 'أؤدي الواجب.',
      topic: 'daily',
      skill: 'recall',
    );

    await repo.recordFacet(
      item: item,
      facetType: ReviewFacetType.meaningRecall,
      answer: 'يفعل',
      correct: true,
      seconds: 5,
      hinted: false,
      at: DateTime.utc(2026, 10, 2, 8),
    );

    expect(sink.events, hasLength(1));
    expect(sink.events.single.facetType, ReviewFacetType.meaningRecall);
    expect(sink.events.single.requestedXp, 10);
  });

  test('clear local data also clears SQLite gamification sink', () async {
    final prefs = await PreferencesService.instance();
    final sink = _Sink();
    final repo = LearnerRepository(
      prefs,
      persistence: LearnerPersistence(
        prefs,
        'phase16_clear',
        'phase16_clear_favorites',
      ),
      gamificationReviewSink: sink,
    );

    await repo.clearLocalData();

    expect(sink.cleared, isTrue);
  });
}
