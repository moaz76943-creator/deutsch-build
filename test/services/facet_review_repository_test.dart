import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('first facet review materializes only that facet row', () async {
    final prefs = await PreferencesService.instance();
    final persistence = LearnerPersistence(
      prefs,
      'phase11_state',
      'phase11_legacy',
    );
    final repository = LearnerRepository(prefs, persistence: persistence);
    const item = ContentItem(
      id: 'noun.tisch',
      german: 'Tisch',
      arabic: 'طاولة',
      sentence: 'Der Tisch ist groß.',
      sentenceAr: 'الطاولة كبيرة.',
      topic: 'home',
      skill: 'recall',
      article: 'der',
    );

    await repository.recordFacet(
      item: item,
      facetType: ReviewFacetType.gender,
      answer: 'der',
      correct: true,
      seconds: 3,
      hinted: false,
      at: DateTime.utc(2026, 10, 2, 12),
    );

    final state = repository.load();
    expect(state.reviewCards, hasLength(1));
    expect(
      state.reviewCardForFacet(item.id, facetType: ReviewFacetType.gender),
      isNotNull,
    );
    expect(state.reviewCards[item.id], isNull);
    expect(state.attempts.single.facetType, ReviewFacetType.gender);
  });

  test('legacy record path remains meaning_recall only', () async {
    final prefs = await PreferencesService.instance();
    final persistence = LearnerPersistence(
      prefs,
      'phase11_state_meaning',
      'phase11_legacy_meaning',
    );
    final repository = LearnerRepository(prefs, persistence: persistence);
    const item = ContentItem(
      id: 'noun.tisch',
      german: 'Tisch',
      arabic: 'طاولة',
      sentence: 'Der Tisch ist groß.',
      sentenceAr: 'الطاولة كبيرة.',
      topic: 'home',
      skill: 'recall',
    );

    await repository.record(
      item: item,
      answer: 'Tisch',
      correct: true,
      seconds: 3,
      hinted: false,
    );

    final state = repository.load();
    expect(state.reviewCards.keys, <String>['noun.tisch']);
    expect(
      state.reviewCards['noun.tisch']?.facetType,
      ReviewFacetType.meaningRecall,
    );
  });
}
