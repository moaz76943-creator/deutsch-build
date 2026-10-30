class MasteryAnalyticsEngine {
  const MasteryAnalyticsEngine();

  double computeCefrMasteryIndex({
    required int masteredCount,
    required double averageRetentionRate,
    required int cefrTargetCount,
  }) {
    if (cefrTargetCount <= 0) return 0.0;
    final double coverage = (masteredCount / cefrTargetCount).clamp(0.0, 1.0);
    return double.parse((coverage * averageRetentionRate * 100.0).toStringAsFixed(1));
  }
}
