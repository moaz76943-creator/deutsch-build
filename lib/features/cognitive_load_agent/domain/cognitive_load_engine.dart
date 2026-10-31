import 'cognitive_load_models.dart';

final class CognitiveLoadEngine {
  const CognitiveLoadEngine();

  CognitiveLoadAnalysis analyze(Iterable<SessionTelemetry> samples) {
    final items = List<SessionTelemetry>.unmodifiable(samples);
    if (items.isEmpty) return CognitiveLoadAnalysis.empty;

    var responseTotal = 0.0;
    var hesitationTotal = 0.0;
    var errorTotal = 0.0;
    var rawResponseTotal = 0.0;
    var rawHesitationTotal = 0.0;
    var rawErrorTotal = 0.0;

    for (final item in items) {
      rawResponseTotal += item.responseTimeMs;
      rawHesitationTotal += item.hesitationCount;
      rawErrorTotal += item.consecutiveErrors;

      responseTotal += _responseLoad(item.responseTimeMs);
      hesitationTotal += _hesitationLoad(item.hesitationCount);
      errorTotal += _errorLoad(item.consecutiveErrors);
    }

    final count = items.length;
    final responseLoad = responseTotal / count;
    final hesitationLoad = hesitationTotal / count;
    final errorLoad = errorTotal / count;

    final loadScore = (
      responseLoad * .45 +
      hesitationLoad * .25 +
      errorLoad * .30
    ).clamp(0.0, 1.0).toDouble();

    final state = _stateFor(loadScore);
    return CognitiveLoadAnalysis(
      state: state,
      loadScore: loadScore,
      focusIndex: (1 - (hesitationLoad * .55 + errorLoad * .45))
          .clamp(0.0, 1.0)
          .toDouble(),
      comprehensionPace: (1 - responseLoad).clamp(0.0, 1.0).toDouble(),
      averageResponseTimeMs: rawResponseTotal / count,
      averageHesitationCount: rawHesitationTotal / count,
      averageConsecutiveErrors: rawErrorTotal / count,
      recommendation: _recommendationFor(state),
    );
  }

  double _responseLoad(int responseTimeMs) {
    if (responseTimeMs <= 2500) return 0;
    return ((responseTimeMs - 2500) / 7500)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double _hesitationLoad(int hesitationCount) =>
      (hesitationCount / 4).clamp(0.0, 1.0).toDouble();

  double _errorLoad(int consecutiveErrors) =>
      (consecutiveErrors / 4).clamp(0.0, 1.0).toDouble();

  CognitiveState _stateFor(double score) {
    if (score < .40) return CognitiveState.optimal;
    if (score < .70) return CognitiveState.fatigue;
    return CognitiveState.overwhelmed;
  }

  PacingRecommendation _recommendationFor(CognitiveState state) {
    return switch (state) {
      CognitiveState.optimal => PacingRecommendation.keepPace,
      CognitiveState.fatigue => const PacingRecommendation(
          action: PacingAction.supportiveHint,
          reducePace: true,
          showSupportHint: true,
          suggestShortBreak: false,
          messageAr: 'خفّف الوتيرة قليلًا. سيظهر تلميح داعم للسؤال التالي.',
        ),
      CognitiveState.overwhelmed => const PacingRecommendation(
          action: PacingAction.shortBreak,
          reducePace: true,
          showSupportHint: true,
          suggestShortBreak: true,
          messageAr: 'الإشارات الحالية مرتفعة. خذ وقفة قصيرة ثم أكمل بوتيرة أخف.',
        ),
    };
  }
}
