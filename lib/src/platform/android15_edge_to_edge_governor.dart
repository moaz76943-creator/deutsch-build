/// Status of Android 15 window insets and predictive navigation gestures.
class Android15InsetsState {
  final bool isEdgeToEdgeEnforced;
  final int topStatusBarPaddingPx;
  final int bottomNavigationBarPaddingPx;
  final bool isPredictiveBackEnabled;

  const Android15InsetsState({
    required this.isEdgeToEdgeEnforced,
    required this.topStatusBarPaddingPx,
    required this.bottomNavigationBarPaddingPx,
    required this.isPredictiveBackEnabled,
  });
}

/// Controls Android 15 transparent system bars and predictive back animation dispatchers.
class Android15EdgeToEdgeGovernor {
  /// Computes safe content viewport insets given physical device cutouts and gesture bar.
  Android15InsetsState computeSafeInsets({
    required int statusBarHeightPx,
    required int navBarHeightPx,
    required bool hasDisplayCutout,
  }) {
    final topPadding = hasDisplayCutout ? statusBarHeightPx + 8 : statusBarHeightPx;

    return Android15InsetsState(
      isEdgeToEdgeEnforced: true,
      topStatusBarPaddingPx: topPadding,
      bottomNavigationBarPaddingPx: navBarHeightPx,
      isPredictiveBackEnabled: true,
    );
  }

  /// Calculates swipe gesture back-animation progress (0.0 to 1.0).
  double computePredictiveBackProgress(double dragDistancePx, {double maxThresholdPx = 150.0}) {
    if (maxThresholdPx <= 0) return 0.0;
    return (dragDistancePx / maxThresholdPx).clamp(0.0, 1.0);
  }
}
