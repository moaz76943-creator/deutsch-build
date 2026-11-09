import '../cognitive/adaptive_cognitive_engine.dart';
import '../cognitive/cognitive_metric_record.dart';
import '../quick_review/quick_review_models.dart';
import '../quick_review/quick_review_service.dart';
import '../memory.dart';

/// Adaptive low-stress review session that dynamically adjusts based on cognitive load.
///
/// Integrates [AdaptiveCognitiveEngine] to reduce session size, simplify presentation,
/// or insert recovery breaks when fatigue is detected. Aligns with roadmap phase 5.
/// All processing is on-device; no network. Metrics stored only in-memory for the session
/// or encrypted local storage if persisted.
final class AdaptiveReviewSession {
  AdaptiveReviewSession({
    required QuickReviewService reviewService,
    AdaptiveCognitiveEngine? cognitiveEngine,
  })  : _reviewService = reviewService,
        _cognitiveEngine = cognitiveEngine ?? AdaptiveCognitiveEngine.instance;

  final QuickReviewService _reviewService;
  final AdaptiveCognitiveEngine _cognitiveEngine;

  static const int _minSessionItems = 5;
  static const Duration _recoveryBreak = Duration(seconds: 30);

  /// Builds a cognitively adapted session.
  ///
  /// Observes recent metrics and reduces limit or flags for simplified UI
  /// when [AdaptationAction.reduceExtraneousLoad] is recommended.
  Future<AdaptiveReviewResult> buildAdaptedSession({
    required Iterable<ReviewCard> reviewCards,
    DateTime? now,
    int preferredLimit = QuickReviewService.defaultSessionItems,
    String? targetLanguageCode,
  }) async {
    final decision = _cognitiveEngine.evaluateDetailedState(
      targetLanguageCode: targetLanguageCode,
      currentTime: now,
    );

    var effectiveLimit = preferredLimit;
    var needsRecoveryBreak = false;
    var simplifyPresentation = false;

    switch (decision.action) {
      case AdaptationAction.reduceExtraneousLoad:
        effectiveLimit = (preferredLimit * 0.6).round().clamp(_minSessionItems, preferredLimit);
        needsRecoveryBreak = true;
        simplifyPresentation = true;
        break;
      case AdaptationAction.deepenLinguisticChallenge:
        // Keep or slightly increase if mastery, but respect max
        effectiveLimit = preferredLimit;
        break;
      case AdaptationAction.maintainFlow:
        effectiveLimit = preferredLimit;
        break;
    }

    final baseSession = await _reviewService.buildSession(
      reviewCards: reviewCards,
      now: now,
      limit: effectiveLimit,
    );

    return AdaptiveReviewResult(
      session: baseSession,
      adaptationDecision: decision,
      effectiveLimit: effectiveLimit,
      needsRecoveryBreak: needsRecoveryBreak,
      simplifyPresentation: simplifyPresentation,
      recommendedBreak: needsRecoveryBreak ? _recoveryBreak : Duration.zero,
    );
  }

  /// Records a metric after a card response to feed the engine.
  void observeResponse(CognitiveMetricRecord record) {
    _cognitiveEngine.observe(record);
  }

  void clearSession({String? targetLanguageCode}) {
    _cognitiveEngine.clearSession(targetLanguageCode: targetLanguageCode);
  }
}

class AdaptiveReviewResult {
  const AdaptiveReviewResult({
    required this.session,
    required this.adaptationDecision,
    required this.effectiveLimit,
    required this.needsRecoveryBreak,
    required this.simplifyPresentation,
    required this.recommendedBreak,
  });

  final QuickReviewSession session;
  final AdaptationDecision adaptationDecision;
  final int effectiveLimit;
  final bool needsRecoveryBreak;
  final bool simplifyPresentation;
  final Duration recommendedBreak;
}
