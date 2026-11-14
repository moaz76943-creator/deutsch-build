import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/fricative_phase_coherent_engine.dart';

void main() {
  group('FricativePhaseCoherentEngine Tests', () {
    const engine = FricativePhaseCoherentEngine();

    test('Synthesizes stable fricative bursts within [-1.0, 1.0]', () {
      final s = engine.synthesizeFricative(type: FricativeType.sAlveolar);
      final sh = engine.synthesizeFricative(type: FricativeType.shPostalveolar);
      final x = engine.synthesizeFricative(type: FricativeType.xVelarAchLaut);

      expect(s.length, greaterThan(0));
      expect(s.every((sample) => sample >= -1.0 && sample <= 1.0), isTrue);
      expect(sh.every((sample) => sample >= -1.0 && sample <= 1.0), isTrue);
      expect(x.every((sample) => sample >= -1.0 && sample <= 1.0), isTrue);
    });

    test('Applies trapezoidal envelope with soft onset and decay', () {
      final fricative = engine.synthesizeFricative(type: FricativeType.fLabiodental);
      expect(fricative.first.abs(), lessThan(0.2));
      expect(fricative.last.abs(), lessThan(0.2));
    });
  });
}
