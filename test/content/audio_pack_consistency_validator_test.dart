import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/content/audio_pack_consistency_validator.dart';

void main() {
  group('AudioPackConsistencyValidator Unit Tests (L091)', () {
    const validator = AudioPackConsistencyValidator(targetLoudnessLufs: -16.0);

    test(
        'Validates clean, normalized audio clips matching target LUFS loudness',
        () {
      final clips = [
        {'duration': 1.8, 'sizeBytes': 24000, 'loudnessLufs': -16.2},
        {'duration': 2.4, 'sizeBytes': 32000, 'loudnessLufs': -15.9},
      ];

      final report = validator.auditClips(clips);
      expect(report.totalClipsChecked, equals(2));
      expect(report.missingOrCorruptedCount, equals(0));
      expect(report.isVolumeNormalized, isTrue);
      expect(report.isPackAudiblyConsistent, isTrue);
    });

    test(
        'Flags clips with non-standard volume deviation or corrupted header length',
        () {
      final taintedClips = [
        {
          'duration': 0.05,
          'sizeBytes': 12,
          'loudnessLufs': -16.0
        }, // Corrupt duration & size
      ];

      final report = validator.auditClips(taintedClips);
      expect(report.missingOrCorruptedCount, equals(1));
      expect(report.isPackAudiblyConsistent, isFalse);
    });
  });
}
