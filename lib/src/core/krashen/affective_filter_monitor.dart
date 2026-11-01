import 'dart:math' as math;

enum PedagogicalIntervention {
  continueOptimalInput, // Filter is low, optimal acquisition conditions
  increaseVisualScaffolding, // Moderate filter, add hints and slower pacing
  offerPraiseAndEncouragement, // Rising anxiety, reduce cognitive pressure
  suggestRestBreak, // High fatigue detected, recommend rest
}

class InteractionMetrics {
  final int responseLatencyMs;
  final int expectedBaselineLatencyMs;
  final int hesitationFillerCount;
  final int consecutiveErrorCount;
  final int sessionDurationSeconds;

  const InteractionMetrics({
    required this.responseLatencyMs,
    required this.expectedBaselineLatencyMs,
    required this.hesitationFillerCount,
    required this.consecutiveErrorCount,
    required this.sessionDurationSeconds,
  });
}

class AffectiveFilterReport {
  final double filterScore; // [0.0 (open/receptive) to 1.0 (blocked/high anxiety)]
  final bool isFatigueDetected;
  final PedagogicalIntervention recommendation;
  final String diagnosticReason;

  const AffectiveFilterReport({
    required this.filterScore,
    required this.isFatigueDetected,
    required this.recommendation,
    required this.diagnosticReason,
  });

  bool get isOptimalReception => filterScore <= 0.35 && !isFatigueDetected;
  bool get isInputObstructed => filterScore >= 0.70;
}

/// Sovereign on-device Affective Filter Monitor.
/// Implements Stephen Krashen's Affective Filter Hypothesis by calculating real-time
/// anxiety and cognitive fatigue from non-verbal interaction signals.
class AffectiveFilterMonitor {
  final int sessionFatigueThresholdSeconds;
  final double latencyWeight;
  final double hesitationWeight;
  final double errorWeight;

  const AffectiveFilterMonitor({
    this.sessionFatigueThresholdSeconds = 1800, // 30 minutes
    this.latencyWeight = 0.35,
    this.hesitationWeight = 0.25,
    this.errorWeight = 0.40,
  });

  /// Evaluates real-time metrics and produces an Affective Filter diagnostic report.
  AffectiveFilterReport evaluateState(InteractionMetrics metrics) {
    // 1. Latency Stress Factor
    double latencyRatio = metrics.responseLatencyMs /
        (metrics.expectedBaselineLatencyMs > 0 ? metrics.expectedBaselineLatencyMs : 1000);
    // If latency is over 2.5x baseline, stress indicator peaks
    double latencyScore = ((latencyRatio - 1.0) / 1.5).clamp(0.0, 1.0);

    // 2. Hesitation Factor (fillers, repeated starts)
    double hesitationScore = (metrics.hesitationFillerCount / 4.0).clamp(0.0, 1.0);

    // 3. Error Burst Factor
    double errorScore = (metrics.consecutiveErrorCount / 3.0).clamp(0.0, 1.0);

    // Composite Filter Score
    double compositeFilter = (latencyScore * latencyWeight) +
        (hesitationScore * hesitationWeight) +
        (errorScore * errorWeight);

    // Fatigue Detection
    bool isFatigued = metrics.sessionDurationSeconds >= sessionFatigueThresholdSeconds &&
        (compositeFilter > 0.45 || metrics.consecutiveErrorCount >= 2);

    if (isFatigued) {
      compositeFilter = math.min(1.0, compositeFilter + 0.25);
    }

    // Recommendation logic
    PedagogicalIntervention intervention;
    String reason;

    if (isFatigued) {
      intervention = PedagogicalIntervention.suggestRestBreak;
      reason = 'تم رصد إجهاد معرفي بعد جلسة تعلم طويلة؛ يُنصح بأخذ قسط من الراحة لتثبيت الذاكرة.';
    } else if (compositeFilter >= 0.70) {
      intervention = PedagogicalIntervention.offerPraiseAndEncouragement;
      reason = 'المرشح العاطفي مرتفع نتيجة توتر أو أخطاء متتالية؛ خفض صعوبة المدخلات وتقديم التشجيع.';
    } else if (compositeFilter > 0.35) {
      intervention = PedagogicalIntervention.increaseVisualScaffolding;
      reason = 'مستوى تردد معتدل؛ إضافة دعائم بصرية وتوضيحات نحوية مبسطة.';
    } else {
      intervention = PedagogicalIntervention.continueOptimalInput;
      reason = 'المرشح العاطفي منخفض ومثالي لاستيعاب مدخلات لغوية متقدمة (i+1).';
    }

    return AffectiveFilterReport(
      filterScore: compositeFilter,
      isFatigueDetected: isFatigued,
      recommendation: intervention,
      diagnosticReason: reason,
    );
  }
}
