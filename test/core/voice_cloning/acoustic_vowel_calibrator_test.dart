import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/voice_cloning/acoustic_vowel_calibrator.dart';

void main() {
  test('N004: AcousticVowelCalibrator checks vowel space', () {
    final cal = AcousticVowelCalibrator();
    expect(cal.isInQuadrilateral(f1: 300, f2: 2000), isTrue);
  });
}
