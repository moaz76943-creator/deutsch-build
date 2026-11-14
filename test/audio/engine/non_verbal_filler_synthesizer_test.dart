import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/non_verbal_filler_synthesizer.dart';

void main() {
  group('NonVerbalFillerSynthesizer Tests', () {
    const synthesizer = NonVerbalFillerSynthesizer();

    test('Synthesizes affirmative "M-hm" filler with characteristic medial dip', () {
      final mhm = synthesizer.synthesizeFiller(NonVerbalFillerType.affirmativeMhm, pitchBaseHz: 120.0);
      expect(mhm.length, equals((16000 * 0.42).round()));
      expect(mhm.every((s) => s >= -1.0 && s <= 1.0), isTrue);

      // Check medial closure dip
      final int mid = mhm.length ~/ 2;
      expect(mhm[mid].abs(), lessThan(mhm[mid ~/ 2].abs()));
    });

    test('Synthesizes contemplative "Hmm" with smooth continuous decay', () {
      final hmm = synthesizer.synthesizeFiller(NonVerbalFillerType.contemplativeHmm, pitchBaseHz: 130.0);
      expect(hmm.length, equals((16000 * 0.65).round()));
      expect(hmm.every((s) => s.isFinite), isTrue);
    });
  });
}
