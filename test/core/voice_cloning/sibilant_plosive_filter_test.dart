import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/voice_cloning/sibilant_plosive_filter.dart';

void main() {
  group('SibilantPlosiveFilter Tests', () {
    const filter = SibilantPlosiveFilter();

    test('Identifies sibilant voiceless friction noise with elevated zero crossing rate', () {
      // Alternating polarity high-frequency noise sample
      final sibilantSample = Int16List.fromList(List.generate(500, (i) => i.isEven ? 4000 : -4000));
      final result = filter.classifyConsonantToken(sibilantSample);

      expect(result.detectedType, equals(ConsonantAcousticType.voicelessSibilantS));
      expect(result.zeroCrossingRate, greaterThan(0.25));
    });

    test('Classifies aspirated German /p/ with positive Voice Onset Time', () {
      final plosiveSample = Int16List.fromList(List.generate(200, (i) => i * 15));
      final result = filter.classifyConsonantToken(plosiveSample);

      expect(result.detectedType, equals(ConsonantAcousticType.voicelessAspiratedP));
      expect(result.voiceOnsetDurationMs, greaterThan(30.0));
    });
  });
}
