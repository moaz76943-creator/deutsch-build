import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/audio/engine/formant_bandwidth_coarticulation_engine.dart';

void main() {
  group('FormantBandwidthCoarticulationEngine Tests', () {
    const engine = FormantBandwidthCoarticulationEngine();

    test('Interpolates smooth coarticulatory trajectory without abrupt jumps', () {
      const consonantLocus = FormantTarget(f1: 200.0, f2: 1800.0, f3: 2600.0);
      const vowelTarget = FormantTarget(f1: 750.0, f2: 1100.0, f3: 2400.0);

      final trajectory = engine.interpolateCoarticulation(
        from: consonantLocus,
        to: vowelTarget,
        stepCount: 8,
      );

      expect(trajectory.length, equals(8));
      expect(trajectory.first.f1, equals(consonantLocus.f1));
      expect(trajectory.last.f1, equals(vowelTarget.f1));
      // Trajectory must be monotonically increasing for F1
      for (int i = 1; i < trajectory.length; i++) {
        expect(trajectory[i].f1, greaterThanOrEqualTo(trajectory[i - 1].f1));
      }
    });

    test('Computes resonance quality factor Q accurately', () {
      final q = engine.calculateResonanceQ(1000.0, 100.0);
      expect(q, equals(10.0));
    });
  });
}
