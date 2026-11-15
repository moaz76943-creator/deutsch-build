import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/voice_cloning/vocal_strain_fatigue_guard.dart';

void main() {
  group('VocalStrainFatigueGuard Tests', () {
    const guard = VocalStrainFatigueGuard();

    test('Identifies relaxed, healthy vocal folds with low fatigue index', () {
      final metrics = guard.assessVocalStrain(
        jitterPercent: 0.65,
        shimmerPercent: 2.10,
        hnrDb: 22.5,
        sessionMinutes: 12,
      );

      expect(metrics.requiresRestBreak, isFalse);
      expect(metrics.vocalFatigueIndex, lessThan(0.3));
      expect(metrics.healthAdvisoryNotice, contains('Stimmbänder klingen klar'));
    });

    test('Triggers ergonomic rest break warning on elevated acoustic shimmer and prolonged session', () {
      final metrics = guard.assessVocalStrain(
        jitterPercent: 1.45,
        shimmerPercent: 5.20,
        hnrDb: 12.0,
        sessionMinutes: 48,
      );

      expect(metrics.requiresRestBreak, isTrue);
      expect(metrics.vocalFatigueIndex, greaterThanOrEqualTo(0.70));
      expect(metrics.healthAdvisoryNotice, contains('Trinke einen Schluck warmes Wasser'));
    });
  });
}
