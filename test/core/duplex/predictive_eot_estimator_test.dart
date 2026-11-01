import 'package:test/test.dart';
import 'package:deutsch_build/src/core/duplex/predictive_eot_estimator.dart';

void main() {
  group('PredictiveEotEstimator Suite', () {
    const estimator = PredictiveEotEstimator();

    test('Fast-tracks turn completion when terminal pitch drops sharply on complete sentence', () {
      final res = estimator.evaluateTurnCompletion(
        recentPartialTranscript: 'أنهيتُ قراءة الكتاب بالكامل',
        terminalPitchSlope: -18.5,
        currentSilenceDurationMs: 160,
      );

      expect(res.isTurnCompleted, isTrue);
      expect(res.action, equals(TurnCompletionAction.yieldTurnToTutor));
      expect(res.dominantCue, equals(EoTCueType.prosodicTerminalFall));
      expect(res.completionProbability, greaterThan(0.90));
    });

    test('Holds floor when sentence terminates on a dangling grammatical conjunction', () {
      final res = estimator.evaluateTurnCompletion(
        recentPartialTranscript: 'ذهبت إلى السوق ولكن',
        terminalPitchSlope: -15.0,
        currentSilenceDurationMs: 300, // Below extended hold threshold (750ms)
      );

      expect(res.isTurnCompleted, isFalse);
      expect(res.action, equals(TurnCompletionAction.holdFloorAwaitContinuation));
      expect(res.dominantCue, equals(EoTCueType.danglingSyntacticConnector));
      expect(res.diagnosticReasonAr, contains('استمرار الاستماع'));
    });
  });
}
