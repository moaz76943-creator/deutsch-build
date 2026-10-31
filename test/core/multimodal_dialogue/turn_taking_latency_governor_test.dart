import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/turn_taking_latency_governor.dart';

void main() {
  group('TurnTakingLatencyGovernor Unit Tests (N062)', () {
    const governor = TurnTakingLatencyGovernor(maxAllowedTurnDelayMs: 120, voiceActivityThreshold: 0.50);

    test('Detects barge-in when energy exceeds threshold while bot speaks', () {
      final bargeIn = governor.detectBargeIn(currentMicrophoneEnergy: 0.75, isBotCurrentlySpeaking: true);
      expect(bargeIn, isTrue);

      final backgroundNoise = governor.detectBargeIn(currentMicrophoneEnergy: 0.20, isBotCurrentlySpeaking: true);
      expect(backgroundNoise, isFalse);
    });

    test('Does not flag barge-in when bot is silent', () {
      final bargeIn = governor.detectBargeIn(currentMicrophoneEnergy: 0.90, isBotCurrentlySpeaking: false);
      expect(bargeIn, isFalse);
    });

    test('Scores 100% fluidity for responses within the 120ms budget', () {
      expect(governor.evaluateTurnPacing(85), equals(100.0));
      expect(governor.evaluateTurnPacing(120), equals(100.0));
      expect(governor.evaluateTurnPacing(350), lessThan(100.0));
    });
  });
}
