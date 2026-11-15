import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/damerau_levenshtein_distance_matrix.dart';
import 'package:deutsch_build/src/core/learning/srs_stability_governor.dart';
import 'package:deutsch_build/src/ui/bridges/vol_114_wave2_ui_bridge.dart';

void main() {
  group('Volume 114 Wave 2 (Tasks 4872-4874) Integration Tests', () {
    test('ARCH-010: SrsStabilityGovernor updates stability and calculates retrievability', () {
      final governor = SrsStabilityGovernor();
      final card = SrsCardState(cardId: 'card_verb_1', stabilityDays: 2.0);

      expect(governor.computeRetrievability(card, card.lastReviewUtc), equals(1.0));

      // Review Good (rating 3)
      final updated = governor.processReview(card, 3);
      expect(updated.repetitionCount, equals(1));
      expect(updated.stabilityDays, greaterThan(card.stabilityDays));

      // Review Lapse (rating 1)
      final lapsed = governor.processReview(updated, 1);
      expect(lapsed.stabilityDays, equals(0.5));
    });

    test('LING-008: DamerauLevenshteinDistanceMatrix detects transpositions and minor typos', () {
      // Adjacent transposition: "leigen" vs "liegen" (common German typo)
      final distTrans = DamerauLevenshteinDistanceMatrix.computeDistance('leigen', 'liegen');
      expect(distTrans, equals(1));
      expect(DamerauLevenshteinDistanceMatrix.isMinorTypo('leigen', 'liegen'), isTrue);

      // Simple insertion: "schuule" vs "schule"
      expect(DamerauLevenshteinDistanceMatrix.computeDistance('schuule', 'schule'), equals(1));

      // Major error: "apfel" vs "orange"
      expect(DamerauLevenshteinDistanceMatrix.isMinorTypo('apfel', 'orange'), isFalse);
    });

    test('UI Bridge correctly generates Wave 2 diagnostics report', () {
      final bridge = Vol114Wave2UIBridge();
      final report = bridge.getWave2Diagnostics();

      expect(report['volume'], equals(114));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['srs_stability_governor']['status'], equals('OPERATIONAL'));
      expect(bridge.checkAnswerForgiving('apfel', 'appfel'), isTrue);
    });
  });
}
