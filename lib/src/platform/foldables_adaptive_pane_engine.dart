/// Viewport layout disposition.
enum ViewportLayoutMode {
  singlePaneCompact, // Standard candybar phone portrait
  dualPaneHorizontalSplit, // Foldable tabletop posture
  dualPaneBookSpanned, // Foldable expanded book posture / Tablet landscape
}

/// Adaptive layout state responding to physical hinge sensors and screen aspect ratios.
class AdaptivePaneConfig {
  final ViewportLayoutMode layoutMode;
  final double leftPaneWidthFraction;
  final double rightPaneWidthFraction;
  final bool hasHingeOcclusion;

  const AdaptivePaneConfig({
    required this.layoutMode,
    required this.leftPaneWidthFraction,
    required this.rightPaneWidthFraction,
    required this.hasHingeOcclusion,
  });
}

/// Adapts reading and dialogue panes dynamically across foldables and tablets.
class FoldablesAdaptivePaneEngine {
  /// Computes adaptive viewport layout according to screen width and hinge posture.
  AdaptivePaneConfig resolveLayout({
    required double windowWidthDp,
    required double windowHeightDp,
    required bool isHingeSeparating,
  }) {
    if (windowWidthDp >= 840 || isHingeSeparating) {
      // Large tablet or book-spanned foldable (50/50 balanced split)
      return AdaptivePaneConfig(
        layoutMode: ViewportLayoutMode.dualPaneBookSpanned,
        leftPaneWidthFraction: 0.50,
        rightPaneWidthFraction: 0.50,
        hasHingeOcclusion: isHingeSeparating,
      );
    }

    if (windowWidthDp >= 600) {
      // Medium foldable unfolded (40/60 master-detail split)
      return const AdaptivePaneConfig(
        layoutMode: ViewportLayoutMode.dualPaneBookSpanned,
        leftPaneWidthFraction: 0.40,
        rightPaneWidthFraction: 0.60,
        hasHingeOcclusion: false,
      );
    }

    // Standard compact phone screen
    return const AdaptivePaneConfig(
      layoutMode: ViewportLayoutMode.singlePaneCompact,
      leftPaneWidthFraction: 1.0,
      rightPaneWidthFraction: 0.0,
      hasHingeOcclusion: false,
    );
  }
}
