import 'package:test/test.dart';
import 'package:deutsch_build/src/core/voice_cloning/spectral_overlay_engine.dart';

void main() {
  test('Generates aligned spectral overlay frames comparing native and learner energy', () {
    const engine = SpectralOverlayEngine();
    final frames = engine.generateOverlay([0.8, 0.9, 0.4], [0.75, 0.85, 0.42]);
    expect(frames.length, equals(3));
    expect(frames[0].spectralDelta, lessThan(0.1));
  });
}
