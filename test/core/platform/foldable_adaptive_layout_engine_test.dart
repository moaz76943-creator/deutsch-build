import 'package:test/test.dart';
import 'package:deutsch_build/src/core/platform/foldable_adaptive_layout_engine.dart';

void main() {
  group('FoldableAdaptiveLayoutEngine Tests', () {
    const engine = FoldableAdaptiveLayoutEngine();

    test('Switches to Dual-Pane Master-Detail on unfolded large tablet screen (840dp)', () {
      const unfoldedScreen = ScreenDimensionsDp(widthDp: 840.0, heightDp: 900.0, hingeAngleDegrees: 180.0);
      final layout = engine.resolveLayout(unfoldedScreen);

      expect(layout.displayMode, equals(LayoutDisplayMode.dualPaneMasterDetail));
      expect(layout.posture, equals(FoldDevicePosture.flatExpanded));
      expect(layout.hasHingeOcclusionSeparation, isTrue);
      expect(layout.primaryPaneWidthDp, greaterThan(400.0));
      expect(layout.secondaryPaneWidthDp, greaterThan(400.0));
    });

    test('Detects Tabletop half-folded posture (110 degrees) for hands-free study mode', () {
      const halfFoldedScreen = ScreenDimensionsDp(widthDp: 720.0, heightDp: 800.0, hingeAngleDegrees: 110.0);
      final layout = engine.resolveLayout(halfFoldedScreen);

      expect(layout.displayMode, equals(LayoutDisplayMode.splitTabletopControls));
      expect(layout.posture, equals(FoldDevicePosture.halfFoldedTabletop));
      expect(layout.hasHingeOcclusionSeparation, isTrue);
    });

    test('Maintains classic single-pane stack for narrow cover screen (380dp)', () {
      const coverScreen = ScreenDimensionsDp(widthDp: 380.0, heightDp: 820.0, hingeAngleDegrees: 0.0);
      final layout = engine.resolveLayout(coverScreen);

      expect(layout.displayMode, equals(LayoutDisplayMode.singlePaneStack));
      expect(layout.posture, equals(FoldDevicePosture.closedCoverScreen));
      expect(layout.secondaryPaneWidthDp, equals(0.0));
    });
  });
}
