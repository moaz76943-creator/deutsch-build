import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/voice_cloning/acoustic_age_normalizer.dart';

void main() {
  group('AcousticAgeNormalizer Tests', () {
    const normalizer = AcousticAgeNormalizer();

    test('Classifies child speaker high pitch (300Hz) and applies downward VTLN warp', () {
      final profile = normalizer.normalizeLearnerFormants(measuredF0: 300.0, rawF1: 400.0, rawF2: 2400.0);

      expect(profile.demographic, equals(SpeakerDemographicGroup.childSpeaker));
      expect(profile.vocalTractWarpingFactorAlpha, lessThan(1.0));
      expect(profile.normalizedF2, lessThan(2400.0));
    });

    test('Classifies adult male low pitch (110Hz) and expands formants to canonical space', () {
      final profile = normalizer.normalizeLearnerFormants(measuredF0: 110.0, rawF1: 300.0, rawF2: 1800.0);

      expect(profile.demographic, equals(SpeakerDemographicGroup.adultMaleSpeaker));
      expect(profile.vocalTractWarpingFactorAlpha, greaterThan(1.0));
    });
  });
}
