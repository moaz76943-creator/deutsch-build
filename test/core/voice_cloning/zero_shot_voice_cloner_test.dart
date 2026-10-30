import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/voice_cloning/zero_shot_voice_cloner.dart';

void main() {
  group('ZeroShotVoiceCloner Tests', () {
    const cloner = ZeroShotVoiceCloner();

    test('Extracts 256-dimensional normalized speaker embedding from sample', () {
      final samplePcm = Int16List.fromList(List.generate(44100 * 3, (i) => (i % 500) * 40));
      final profile = cloner.extractSpeakerProfile(samplePcm);

      expect(profile.dVector.length, equals(256));
      expect(profile.fundamentalFrequencyF0, greaterThanOrEqualTo(85.0));
      expect(profile.fundamentalFrequencyF0, lessThanOrEqualTo(260.0));
    });

    test('Synthesizes German text in learner cloned voice with high cosine similarity', () {
      final samplePcm = Int16List(44100 * 2);
      final profile = cloner.extractSpeakerProfile(samplePcm);

      final result = cloner.synthesizeInLearnerVoice('Ich spreche Deutsch fließend.', profile);

      expect(result.synthesizedPcmSamples.isNotEmpty, isTrue);
      expect(result.cosineSimilarityScore, greaterThan(0.85));
      expect(result.audioDurationMs, greaterThan(500));
    });

    test('Throws error if audio sample is shorter than 2 seconds', () {
      final shortPcm = Int16List(5000);
      expect(() => cloner.extractSpeakerProfile(shortPcm), throwsA(isA<ArgumentError>()));
    });
  });
}
