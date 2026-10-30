import 'package:test/test.dart';
import 'package:deutsch_build/src/core/voice_cloning/vowel_formant_calibrator.dart';

void main() {
  test('Calibrates German vowel y: and approves close native formants', () {
    const calibrator = VowelFormantCalibrator();
    final report = calibrator.calibrateVowel(vowelKey: 'y:', measuredF1: 295.0, measuredF2: 2020.0);
    expect(report.isWithinNativeRange, isTrue);
    expect(report.euclideanDistance, lessThan(50.0));
  });
}
