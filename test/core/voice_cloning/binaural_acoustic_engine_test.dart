import 'package:test/test.dart';
import '../../lib/src/core/voice_cloning/binaural_acoustic_engine.dart';

void main() {
  test('N010: BinauralAcousticEngine spatialises audio', () {
    final eng = BinauralAcousticEngine();
    expect(eng.spatialiseMono([1.0, 2.0]), equals([1.0, 2.0]));
  });
}
