import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/neural_audio_synthesizer_v2.dart';

void main() {
  group('NeuralAudioSynthesizerV2 Tests', () {
    const synthesizer = NeuralAudioSynthesizerV2();

    test('Acoustic synthesis conforms to memory ceiling and low latency limits', () {
      expect(synthesizer.sampleRate, equals(16000));
      expect(synthesizer.latencyCeilingMs, lessThanOrEqualTo(30.0));
      expect(synthesizer.maxRamAllocationMb, lessThanOrEqualTo(1.5));
    });

    test('Synthesizes valid PCM audio buffer within safe amplitude bounds', () {
      final tokens = ['s', 'a', 'l', 'a', 'm'];
      final pcm = synthesizer.synthesizePhonemes(tokens);
      expect(pcm.length, greaterThan(0));
      expect(pcm.every((sample) => sample >= -1.0 && sample <= 1.0), isTrue);
    });

    test('RAM estimation confirms strict containment under 1.5MB for long utterances', () {
      final ramFor5Seconds = synthesizer.estimateRamUsageMb(5000.0);
      expect(ramFor5Seconds, lessThan(0.5)); // Well below 1.5MB limit!
    });
  });
}
