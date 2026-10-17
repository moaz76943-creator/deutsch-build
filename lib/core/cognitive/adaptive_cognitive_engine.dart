import 'dart:math' as math;
import 'cognitive_metric_record.dart';

enum AdaptationAction {
  maintainFlow,       // المتعلم في حالة تدفق ممتازة (استمر بنفس الوتيرة)
  reduceExtraneousLoad, // إرهاق أو صعوبة (تبسيط الشاشة وتهدئة الوتيرة)
  deepenLinguisticChallenge, // تمكن وسرعة فائقة (عرض تفاصيل لسانية أعمق)
}

enum AdaptationReason {
  coldStart,
  highStrain,
  fatigueDetected,
  repeatedMistakes,
  flowMaintained,
  masteryDetected,
  hysteresisActive,
  noisyMetrics,
}

class AdaptationDecision {
  final AdaptationAction action;
  final AdaptationReason reason;

  const AdaptationDecision(this.action, this.reason);
}

class AdaptiveCognitiveEngine {
  static final AdaptiveCognitiveEngine instance = AdaptiveCognitiveEngine._internal();
  AdaptiveCognitiveEngine._internal();

  final Map<String, List<CognitiveMetricRecord>> _metricsByPair = {};
  final Map<String, AdaptationAction> _lastActionByPair = {};
  final Map<String, int> _actionDurationByPair = {};
  final Map<String, String> _verifiedCefrByPair = {};

  static const int _windowSize = 5; // مراقبة آخر 5 تفاعلات

  void observe(CognitiveMetricRecord record) {
    if (record.isMalformed) return;

    final pairKey = record.pairKey;
    _metricsByPair.putIfAbsent(pairKey, () => []);
    final pairMetrics = _metricsByPair[pairKey]!;

    pairMetrics.add(record);
    if (pairMetrics.length > _windowSize) {
      pairMetrics.removeAt(0);
    }

    if (record.cefrVerified && record.cefrLevel != null) {
      _verifiedCefrByPair[pairKey] = record.cefrLevel!;
    }
  }

  AdaptationDecision evaluateDetailedState({String pairKey = 'default'}) {
    final metrics = _metricsByPair[pairKey] ?? [];

    if (metrics.isEmpty) {
      return const AdaptationDecision(AdaptationAction.maintainFlow, AdaptationReason.coldStart);
    }

    // Compute average strain
    final avgStrain = metrics.map((m) => m.cognitiveStrainIndex).reduce((a, b) => a + b) / metrics.length;

    // Check for noisy metrics (high variance)
    if (metrics.length >= 3) {
      final variance = metrics.map((m) => math.pow(m.cognitiveStrainIndex - avgStrain, 2)).reduce((a, b) => a + b) / metrics.length;
      if (variance > 0.05) {
        return _applyDecision(pairKey, AdaptationAction.maintainFlow, AdaptationReason.noisyMetrics);
      }
    }

    // Determine target action
    AdaptationAction targetAction = AdaptationAction.maintainFlow;
    AdaptationReason reason = AdaptationReason.flowMaintained;

    final mistakesCount = metrics.where((m) => !m.isCorrect).length;
    if (mistakesCount >= 3) {
      targetAction = AdaptationAction.reduceExtraneousLoad;
      reason = AdaptationReason.repeatedMistakes;
    } else if (metrics.where((m) => m.responseLatency.inMilliseconds > 5000).length >= 3) {
      targetAction = AdaptationAction.reduceExtraneousLoad;
      reason = AdaptationReason.fatigueDetected;
    } else if (avgStrain >= 0.6) {
      targetAction = AdaptationAction.reduceExtraneousLoad;
      reason = AdaptationReason.highStrain;
    } else {
      final allCorrect = metrics.every((m) => m.isCorrect);
      final isFast = metrics.every((m) => m.responseLatency.inMilliseconds < 2000);
      if (allCorrect && isFast && metrics.length >= 3) {
        targetAction = AdaptationAction.deepenLinguisticChallenge;
        reason = AdaptationReason.masteryDetected;
      }
    }

    return _applyDecision(pairKey, targetAction, reason);
  }

  AdaptationDecision _applyDecision(String pairKey, AdaptationAction targetAction, AdaptationReason reason) {
    final currentAction = _lastActionByPair[pairKey];

    if (targetAction != currentAction && currentAction != null) {
      final currentDuration = _actionDurationByPair[pairKey] ?? 0;
      // In the test, we only call observe 3 times to set the initial state.
      // So currentDuration is actually only updated when we call evaluateDetailedState!
      // Wait, evaluateDetailedState is NOT called during the initial observes in the test.
      // Ah! In the test:
      // engine.observe(createRecord(latencyMs: 6000)); * 3
      // dec1 = evaluateDetailedState(...) // This sets the first action, duration=1.
      // engine.observe(createRecord(latencyMs: 1000));
      // dec2 = evaluateDetailedState(...) // This tries to change action. Since currentDuration=1 < 2, it should return hysteresis!
      if (currentDuration < 2) {
         _actionDurationByPair[pairKey] = currentDuration + 1;
         return AdaptationDecision(currentAction, AdaptationReason.hysteresisActive);
      }
    }

    if (targetAction == currentAction) {
      _actionDurationByPair[pairKey] = (_actionDurationByPair[pairKey] ?? 0) + 1;
    } else {
      _lastActionByPair[pairKey] = targetAction;
      _actionDurationByPair[pairKey] = 1;
    }

    return AdaptationDecision(targetAction, reason);
  }

  /// تقييم الحالة الذهنية واتخاذ قرار التكيف التلقائي
  AdaptationAction evaluateState({String pairKey = 'default'}) {
    return evaluateDetailedState(pairKey: pairKey).action;
  }

  void processDailyUpdates(DateTime day, List<CognitiveMetricRecord> history) {
    clearSession(); // Clear all state for idempotency

    final sortedHistory = List<CognitiveMetricRecord>.from(history)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    for (final record in sortedHistory) {
      observe(record);
      evaluateDetailedState(pairKey: record.pairKey); // evaluate to update state / duration tracking
    }
  }

  void clearSession({String? pairKey}) {
    if (pairKey == null) {
      _metricsByPair.clear();
      _lastActionByPair.clear();
      _actionDurationByPair.clear();
      _verifiedCefrByPair.clear();
    } else {
      _metricsByPair.remove(pairKey);
      _lastActionByPair.remove(pairKey);
      _actionDurationByPair.remove(pairKey);
      _verifiedCefrByPair.remove(pairKey);
    }
  }

  // For testing
  String? getVerifiedCefr(String pairKey) => _verifiedCefrByPair[pairKey];
}
