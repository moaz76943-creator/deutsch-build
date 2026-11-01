import 'package:test/test.dart';
import 'package:deutsch_build/src/audio/engine/speaker_diarization_turn_coordinator.dart';

void main() {
  group('SpeakerDiarizationTurnCoordinator Tests', () {
    const coordinator = SpeakerDiarizationTurnCoordinator();

    test('Computes voiceprint cosine similarity accurately', () {
      final embedding1 = List<double>.generate(128, (i) => i.toDouble());
      final embedding2 = List<double>.generate(128, (i) => i.toDouble());
      final divergent = List<double>.generate(128, (i) => (128 - i).toDouble());

      final matchScore = coordinator.computeVoiceprintSimilarity(embedding1, embedding2);
      final divergentScore = coordinator.computeVoiceprintSimilarity(embedding1, divergent);

      expect(matchScore, closeTo(1.0, 1e-5));
      expect(divergentScore, lessThan(0.8));
      expect(coordinator.isLearnerActive(embedding1, embedding2), isTrue);
    });

    test('Turn coordinator respects thinking pauses and takes floor upon sentence completion', () {
      // 1. User is speaking
      expect(
        coordinator.evaluateTurnState(isSpeechDetected: true, currentSilenceDurationMs: 0, isSyntacticSentenceComplete: false),
        equals(ConversationalTurnState.listeningToLearner),
      );

      // 2. User pauses for 300ms mid-sentence (thinking pause)
      expect(
        coordinator.evaluateTurnState(isSpeechDetected: false, currentSilenceDurationMs: 300, isSyntacticSentenceComplete: false),
        equals(ConversationalTurnState.anticipatingCompletion),
      );

      // 3. User finishes sentence and pauses for 500ms
      expect(
        coordinator.evaluateTurnState(isSpeechDetected: false, currentSilenceDurationMs: 500, isSyntacticSentenceComplete: true),
        equals(ConversationalTurnState.takingTurnAiSpeaking),
      );
    });
  });
}
