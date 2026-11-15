import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/platform/android15_edge_to_edge_governor.dart';

void main() {
  group('Android15EdgeToEdgeGovernor Unit Tests (N089)', () {
    final governor = Android15EdgeToEdgeGovernor();

    test('Computes edge-to-edge window insets accounting for camera cutout', () {
      final state = governor.computeSafeInsets(
        statusBarHeightPx: 48,
        navBarHeightPx: 24,
        hasDisplayCutout: true,
      );

      expect(state.isEdgeToEdgeEnforced, isTrue);
      expect(state.topStatusBarPaddingPx, equals(56)); // 48 + 8 cutout buffer
      expect(state.bottomNavigationBarPaddingPx, equals(24));
      expect(state.isPredictiveBackEnabled, isTrue);
    });

    test('Calculates smooth predictive back gesture progress (0.0 to 1.0)', () {
      expect(governor.computePredictiveBackProgress(75.0, maxThresholdPx: 150.0), equals(0.5));
      expect(governor.computePredictiveBackProgress(200.0, maxThresholdPx: 150.0), equals(1.0)); // Clamped
      expect(governor.computePredictiveBackProgress(0.0), equals(0.0));
    });
  });
}
