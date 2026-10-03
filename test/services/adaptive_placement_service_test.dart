import 'package:deutsch_bilarabi/models/diagnostic_placement.dart';
import 'package:deutsch_bilarabi/services/adaptive_placement_service.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'recording placement stores history without fabricating mastery or XP',
    () async {
      final prefs = await PreferencesService.instance();
      final persistence = LearnerPersistence(
        prefs,
        'phase12_state',
        'phase12_legacy',
      );
      final repository = LearnerRepository(prefs, persistence: persistence);
      final before = repository.load();

      const result = PlacementDiagnosticResult(
        answered: 8,
        scoredAnswers: 8,
        cleanCorrect: 5,
        score: 62.5,
        confidence: .8,
        band: DiagnosticPlacementBand.developing,
        dimensionScores: <DiagnosticDimension, double>{
          DiagnosticDimension.meaning: .8,
          DiagnosticDimension.grammar: .5,
        },
        weakDimensions: <DiagnosticDimension>[DiagnosticDimension.grammar],
        reviewItemIds: <String>['item_4'],
      );

      await AdaptivePlacementService(repository)
          .recordResult(result, at: DateTime.utc(2026, 10, 2, 12));

      final after = repository.load();
      expect(after.xp, before.xp);
      expect(after.learned, before.learned);
      expect(after.reviewCards, before.reviewCards);
      expect(after.assessmentHistory, isEmpty);
      expect(after.placementHistory, hasLength(1));
      expect(
        after.placementHistory.single.band,
        DiagnosticPlacementBand.developing,
      );
      expect(
        after.placementHistory.single.weakDimensions,
        contains(DiagnosticDimension.grammar),
      );
    },
  );
}
