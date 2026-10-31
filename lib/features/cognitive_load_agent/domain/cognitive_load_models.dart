enum CognitiveState { optimal, fatigue, overwhelmed }

enum PacingAction { keepPace, reducePace, supportiveHint, shortBreak }

final class SessionTelemetry {
  SessionTelemetry({
    required this.eventId,
    required DateTime occurredAtUtc,
    required int responseTimeMs,
    required int hesitationCount,
    required int consecutiveErrors,
  })  : occurredAtUtc = occurredAtUtc.toUtc(),
        responseTimeMs = responseTimeMs.clamp(0, 120000).toInt(),
        hesitationCount = hesitationCount.clamp(0, 20).toInt(),
        consecutiveErrors = consecutiveErrors.clamp(0, 20).toInt() {
    if (eventId.trim().isEmpty || eventId.length > 160) {
      throw ArgumentError.value(eventId, 'eventId', 'invalid telemetry id');
    }
  }

  final String eventId;
  final DateTime occurredAtUtc;
  final int responseTimeMs;
  final int hesitationCount;
  final int consecutiveErrors;
}

final class PacingRecommendation {
  const PacingRecommendation({
    required this.action,
    required this.reducePace,
    required this.showSupportHint,
    required this.suggestShortBreak,
    required this.messageAr,
  });

  final PacingAction action;
  final bool reducePace;
  final bool showSupportHint;
  final bool suggestShortBreak;
  final String messageAr;

  static const keepPace = PacingRecommendation(
    action: PacingAction.keepPace,
    reducePace: false,
    showSupportHint: false,
    suggestShortBreak: false,
    messageAr: 'وتيرتك مستقرة. استمر بنفس الإيقاع.',
  );
}

final class CognitiveLoadAnalysis {
  const CognitiveLoadAnalysis({
    required this.state,
    required this.loadScore,
    required this.focusIndex,
    required this.comprehensionPace,
    required this.averageResponseTimeMs,
    required this.averageHesitationCount,
    required this.averageConsecutiveErrors,
    required this.recommendation,
  });

  final CognitiveState state;
  final double loadScore;
  final double focusIndex;
  final double comprehensionPace;
  final double averageResponseTimeMs;
  final double averageHesitationCount;
  final double averageConsecutiveErrors;
  final PacingRecommendation recommendation;

  static const empty = CognitiveLoadAnalysis(
    state: CognitiveState.optimal,
    loadScore: 0,
    focusIndex: 1,
    comprehensionPace: 1,
    averageResponseTimeMs: 0,
    averageHesitationCount: 0,
    averageConsecutiveErrors: 0,
    recommendation: PacingRecommendation.keepPace,
  );
}
