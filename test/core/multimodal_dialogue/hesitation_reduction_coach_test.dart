import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/hesitation_reduction_coach.dart';

void main() {
  group('HesitationReductionCoach Unit Tests (N076)', () {
    const coach = HesitationReductionCoach(silenceAlertThresholdSeconds: 4.0);

    test('Does not interrupt natural short thinking pauses (< 4.0s)', () {
      final intervention = coach.checkSilence(currentSilenceSeconds: 2.5, currentTopic: 'essen');
      expect(intervention.requiresIntervention, isFalse);
      expect(intervention.supportiveCue, isEmpty);
    });

    test('Intervenes with supportive sentence starter when silence exceeds threshold', () {
      final intervention = coach.checkSilence(currentSilenceSeconds: 5.2, currentTopic: 'essen');
      expect(intervention.requiresIntervention, isTrue);
      expect(intervention.supportiveCue, contains('Ich esse gern'));
      expect(intervention.confidenceScore, lessThan(0.60));
    });
  });
}
