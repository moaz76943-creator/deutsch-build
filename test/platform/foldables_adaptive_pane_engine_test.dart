import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/platform/foldables_adaptive_pane_engine.dart';

void main() {
  group('FoldablesAdaptivePaneEngine Unit Tests (N097)', () {
    final engine = FoldablesAdaptivePaneEngine();

    test(
        'Configures compact single-pane mode for standard phone screens (<600dp)',
        () {
      final config = engine.resolveLayout(
          windowWidthDp: 390, windowHeightDp: 844, isHingeSeparating: false);
      expect(config.layoutMode, equals(ViewportLayoutMode.singlePaneCompact));
      expect(config.leftPaneWidthFraction, equals(1.0));
      expect(config.rightPaneWidthFraction, equals(0.0));
    });

    test(
        'Configures dual-pane spanned mode for large foldable tablet screens (>=840dp)',
        () {
      final config = engine.resolveLayout(
          windowWidthDp: 900, windowHeightDp: 1200, isHingeSeparating: true);
      expect(config.layoutMode, equals(ViewportLayoutMode.dualPaneBookSpanned));
      expect(config.leftPaneWidthFraction, equals(0.50));
      expect(config.rightPaneWidthFraction, equals(0.50));
      expect(config.hasHingeOcclusion, isTrue);
    });
  });
}
