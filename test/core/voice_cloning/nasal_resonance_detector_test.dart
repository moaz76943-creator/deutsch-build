import 'package:test/test.dart';
import '../../lib/src/core/voice_cloning/nasal_resonance_detector.dart';

void main() {
  test('N009: NasalResonanceDetector detects nasality', () {
    final det = NasalResonanceDetector();
    expect(det.isNasalized(nasalEnergy: 50, oralEnergy: 80), isTrue);
  });
}
