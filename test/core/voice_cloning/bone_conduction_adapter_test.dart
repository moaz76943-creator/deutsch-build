import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/core/voice_cloning/bone_conduction_adapter.dart';

void main() {
  group('BoneConductionAdapter Unit Tests (N018)', () {
    test(
        'Limiter retains the soft knee and saturates without exponential overflow',
        () {
      const adapter =
          BoneConductionAdapter(profile: BoneConductionProfile.standard);
      final output = adapter
          .adaptSamples([0.5, -0.5, 0.85, -0.85, 0.925, -0.925, 1e300, -1e300]);

      expect(output.take(4), orderedEquals([0.5, -0.5, 0.85, -0.85]));
      expect(output[4], closeTo(0.9193175736, 1e-10));
      expect(output[5], closeTo(-0.9193175736, 1e-10));
      expect(output[6], 1.0);
      expect(output[7], -1.0);
      expect(output.every((value) => value.isFinite), isTrue);
    });

    test('Clarity boost modifies frequency spectrum without clipping', () {
      const adapter = BoneConductionAdapter(
        profile: BoneConductionProfile.speechClarityBoost,
      );
      final raw = List<double>.generate(200, (i) => math.sin(i * 0.2));
      final adapted = adapter.adaptSamples(raw);

      expect(adapted.length, equals(raw.length));
      for (final s in adapted) {
        expect(s, inInclusiveRange(-1.0, 1.0));
      }
      expect(adapter.evaluateClarity(adapted), greaterThan(0.0));
    });

    test('Anti-rattle limiter contains high amplitude vibrations', () {
      const adapter = BoneConductionAdapter(
        profile: BoneConductionProfile.bassCompensated,
        cranialAbsorptionFactor: 2.0,
        enableRattleLimiter: true,
      );
      final extremeSamples = [0.95, 1.2, -1.5, 0.99];
      final processed = adapter.adaptSamples(extremeSamples);

      for (final s in processed) {
        expect(s.abs(), lessThanOrEqualTo(1.0));
      }
    });

    test('Empty samples handling', () {
      const adapter = BoneConductionAdapter();
      expect(adapter.adaptSamples([]), isEmpty);
      expect(adapter.evaluateClarity([]), equals(0.0));
    });
  });
}
