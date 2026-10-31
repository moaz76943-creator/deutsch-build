import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/prosody_emotion_modulator.dart';

void main() {
  group('ProsodyEmotionModulator Unit Tests (N074)', () {
    final modulator = ProsodyEmotionModulator();

    test('Curious inquiry applies sentence-final intonation rise (+25Hz)', () {
      final params = modulator.computeParameters(ConversationalEmotion.curiousInquiry);
      expect(params.finalIntonationRiseHz, greaterThan(20.0));
      expect(params.speechTempo, equals(1.0));
    });

    test('Celebratory excitement boosts energy and pitch shift', () {
      final params = modulator.computeParameters(ConversationalEmotion.celebratoryExcitement);
      expect(params.pitchShiftSemitones, greaterThan(2.0));
      expect(params.energyMultiplier, greaterThan(1.2));
      expect(params.speechTempo, greaterThan(1.0));
    });

    test('Neutral clarity maintains zero shift baseline', () {
      final params = modulator.computeParameters(ConversationalEmotion.neutralClarity);
      expect(params.pitchShiftSemitones, equals(0.0));
      expect(params.energyMultiplier, equals(1.0));
    });
  });
}
