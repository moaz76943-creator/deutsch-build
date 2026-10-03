import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/session/universal_session_orchestrator.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FakeHaptics implements SessionHapticDriver {
  int correctCalls = 0;
  int incorrectCalls = 0;
  int lastCombo = 0;

  @override
  Future<void> onCorrect({required int combo}) async {
    correctCalls++;
    lastCombo = combo;
  }

  @override
  Future<void> onIncorrect() async {
    incorrectCalls++;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('orchestrator derives XP, combo and SRS facet state from repository', () async {
    final prefs = await PreferencesService.instance();
    final persistence = LearnerPersistence(
      prefs,
      LearnerRepository.key,
      LearnerRepository.legacyFavoriteKey,
    );
    final repository = LearnerRepository(
      prefs,
      persistence: persistence,
    );
    final haptics = _FakeHaptics();
    final orchestrator = UniversalSessionOrchestrator(
      repository: repository,
      haptics: haptics,
    );
    const item = ContentItem(
      id: 'noun.tisch',
      german: 'der Tisch',
      arabic: 'الطاولة',
      sentence: 'Der Tisch ist groß.',
      sentenceAr: 'الطاولة كبيرة.',
      topic: 'الحياة اليومية',
      skill: 'recall',
      article: 'der',
      plural: 'die Tische',
    );

    await orchestrator.record(
      SessionReviewInput(
        item: item,
        answer: 'der',
        correct: true,
        seconds: 2,
        facetType: ReviewFacetType.gender,
      ),
    );
    await orchestrator.record(
      SessionReviewInput(
        item: item,
        answer: 'Tisch',
        correct: true,
        seconds: 2,
        facetType: ReviewFacetType.pronunciation,
        variantKey: 'word',
      ),
    );

    expect(orchestrator.state.answered, 2);
    expect(orchestrator.state.correct, 2);
    expect(orchestrator.state.combo, 2);
    expect(orchestrator.state.bestCombo, 2);
    expect(orchestrator.state.sessionXp, greaterThan(0));
    expect(haptics.correctCalls, 2);
    expect(haptics.lastCombo, 2);

    final persisted = await repository.reloadPersisted();
    expect(
      persisted.reviewCardForFacet(
        item.id,
        facetType: ReviewFacetType.gender,
      ),
      isNotNull,
    );
    expect(
      persisted.reviewCardForFacet(
        item.id,
        facetType: ReviewFacetType.pronunciation,
        variantKey: 'word',
      ),
      isNotNull,
    );

    await orchestrator.record(
      SessionReviewInput(
        item: item,
        answer: 'die',
        correct: false,
        seconds: 3,
        facetType: ReviewFacetType.gender,
      ),
    );
    expect(orchestrator.state.combo, 0);
    expect(orchestrator.state.answered, 3);
    expect(haptics.incorrectCalls, 1);
  });
}
