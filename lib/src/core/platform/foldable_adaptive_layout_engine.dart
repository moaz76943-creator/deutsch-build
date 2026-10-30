enum FoldDevicePosture {
  flatExpanded,    // Fully opened tablet/foldable (180 deg)
  halfFoldedTabletop, // Laptop / Tabletop mode (90 deg - 135 deg)
  closedCoverScreen,  // Single standard phone screen (< 600dp width)
}

enum LayoutDisplayMode {
  singlePaneStack,
  dualPaneMasterDetail,
  splitTabletopControls,
}

class ScreenDimensionsDp {
  final double widthDp;
  final double heightDp;
  final double hingeAngleDegrees;

  const ScreenDimensionsDp({
    required this.widthDp,
    required this.heightDp,
    this.hingeAngleDegrees = 180.0,
  });
}

class AdaptiveLayoutDecision {
  final LayoutDisplayMode displayMode;
  final FoldDevicePosture posture;
  final double primaryPaneWidthDp;
  final double secondaryPaneWidthDp;
  final bool hasHingeOcclusionSeparation;

  const AdaptiveLayoutDecision({
    required this.displayMode,
    required this.posture,
    required this.primaryPaneWidthDp,
    required this.secondaryPaneWidthDp,
    required this.hasHingeOcclusionSeparation,
  });

  Map<String, dynamic> toJson() => {
    'displayMode': displayMode.name,
    'posture': posture.name,
    'primaryPaneWidthDp': primaryPaneWidthDp,
    'secondaryPaneWidthDp': secondaryPaneWidthDp,
    'hasHingeOcclusionSeparation': hasHingeOcclusionSeparation,
  };
}

class FoldableAdaptiveLayoutEngine {
  static const double largeDisplayThresholdDp = 680.0;

  const FoldableAdaptiveLayoutEngine();

  /// Resolves optimal dual-pane or single-pane layout based on screen geometry and hinge angle.
  AdaptiveLayoutDecision resolveLayout(ScreenDimensionsDp screen) {
    FoldDevicePosture posture;
    if (screen.hingeAngleDegrees > 80.0 && screen.hingeAngleDegrees < 140.0) {
      posture = FoldDevicePosture.halfFoldedTabletop;
    } else if (screen.widthDp >= largeDisplayThresholdDp) {
      posture = FoldDevicePosture.flatExpanded;
    } else {
      posture = FoldDevicePosture.closedCoverScreen;
    }

    if (posture == FoldDevicePosture.halfFoldedTabletop) {
      return AdaptiveLayoutDecision(
        displayMode: LayoutDisplayMode.splitTabletopControls,
        posture: posture,
        primaryPaneWidthDp: screen.widthDp,
        secondaryPaneWidthDp: screen.widthDp,
        hasHingeOcclusionSeparation: true,
      );
    }

    if (screen.widthDp >= largeDisplayThresholdDp) {
      // Split 50/50 dual pane for large unfolded screens
      final halfWidth = (screen.widthDp - 16.0) / 2.0; // 16dp hinge/separator gap
      return AdaptiveLayoutDecision(
        displayMode: LayoutDisplayMode.dualPaneMasterDetail,
        posture: FoldDevicePosture.flatExpanded,
        primaryPaneWidthDp: double.parse(halfWidth.toStringAsFixed(1)),
        secondaryPaneWidthDp: double.parse(halfWidth.toStringAsFixed(1)),
        hasHingeOcclusionSeparation: true,
      );
    }

    // Default compact phone layout
    return AdaptiveLayoutDecision(
      displayMode: LayoutDisplayMode.singlePaneStack,
      posture: FoldDevicePosture.closedCoverScreen,
      primaryPaneWidthDp: screen.widthDp,
      secondaryPaneWidthDp: 0.0,
      hasHingeOcclusionSeparation: false,
    );
  }
}
