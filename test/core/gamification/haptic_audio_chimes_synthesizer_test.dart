import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/gamification/haptic_audio_chimes_synthesizer.dart';

void main() {
  group('HapticAudioChimesSynthesizer Tests', () {
    const synth = HapticAudioChimesSynthesizer();

    test('Success chime generates non-empty PCM samples within 16-bit boundaries', () {
      final pcm = synth.synthesizeSuccessChime();

      expect(pcm.isNotEmpty, isTrue);
      expect(pcm.length, greaterThan(2000));

      // Verify no clipping overflow
      for (final sample in pcm) {
        expect(sample, greaterThanOrEqualTo(-32768));
        expect(sample, lessThanOrEqualTo(32767));
      }
    });

    test('Fanfare chime produces longer celebratory audio profile', () {
      final success = synth.synthesizeSuccessChime();
      final fanfare = synth.synthesizeLevelUpFanfare();

      expect(fanfare.length, greaterThan(success.length));
    });

    test('Haptic patterns output positive pulse sequences', () {
      final pulses = synth.getHapticPattern(HapticPatternType.successDoublePulse);

      expect(pulses.length, equals(3));
      expect(pulses.first.durationMs, equals(15));
      expect(pulses.last.intensity, greaterThan(0.8));
    });
  });
}
