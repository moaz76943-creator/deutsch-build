import 'cognitive_metric_record.dart';

enum AdaptationAction {
  maintainFlow, // المتعلم في حالة تدفق ممتازة (استمر بنفس الوتيرة)
  reduceExtraneousLoad, // إرهاق أو صعوبة (تبسيط الشاشة وتهدئة الوتيرة)
  deepenLinguisticChallenge, // تمكن وسرعة فائقة (عرض تفاصيل لسانية أعمق)
}

sealed class AdaptationReason {
  const AdaptationReason();
}

class FatigueDetected extends AdaptationReason {
  const FatigueDetected();
}

class ConsistentMastery extends AdaptationReason {
  const ConsistentMastery();
}

class HysteresisCoolDown extends AdaptationReason {
  const HysteresisCoolDown();
}

class InsufficientData extends AdaptationReason {
  const InsufficientData();
}

class StableFlow extends AdaptationReason {
  const StableFlow();
}

class BlockedUnverified extends AdaptationReason {
  const BlockedUnverified();
}

class AdaptationDecision {
  final AdaptationAction action;
  final AdaptationReason reason;

  const AdaptationDecision(this.action, this.reason);
}

class AdaptiveCognitiveEngine {
  static final AdaptiveCognitiveEngine instance = AdaptiveCognitiveEngine._internal();
  AdaptiveCognitiveEngine._internal();

  static const String _defaultPairKey = 'default_pair';
  final Map<String, List<CognitiveMetricRecord>> _metricsByPair = {};

  // Hysteresis tracking
  final Map<String, DateTime> _lastActionTime = {};
  final Map<String, AdaptationAction> _lastAction = {};

  static const int _windowSize = 20; // Bound history to 20 items per pair
  static const Duration _hysteresisDuration = Duration(minutes: 5); // 5 minutes cooldown

  String _getPairKey(String? targetLanguageCode) => targetLanguageCode ?? _defaultPairKey;

  void observe(CognitiveMetricRecord record) {
    final pairKey = _getPairKey(record.targetLanguageCode);

    if (!_metricsByPair.containsKey(pairKey)) {
      _metricsByPair[pairKey] = [];
    }

    final metrics = _metricsByPair[pairKey]!;
    metrics.add(record);

    if (metrics.length > _windowSize) {
      metrics.removeAt(0);
    }

    // Idempotent daily cleanup: remove records older than 24 hours for this pair
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 24));
    metrics.removeWhere((m) => m.recordedAt.isBefore(cutoff));
  }

  /// Evaluates detailed state with reason and pair isolation
  AdaptationDecision evaluateDetailedState({String? targetLanguageCode, DateTime? currentTime}) {
    final pairKey = _getPairKey(targetLanguageCode);
    final metrics = _metricsByPair[pairKey] ?? [];

    // Fallback if empty/cold-start
    if (metrics.isEmpty) {
      return const AdaptationDecision(AdaptationAction.maintainFlow, InsufficientData());
    }

    final now = currentTime ?? DateTime.now();

    // Determine state from recent metrics (last 5 for actual logic, while preserving 20 for history)
    final recentWindow = metrics.length > 5 ? metrics.sublist(metrics.length - 5) : metrics;

    final sumStrain = recentWindow.map((m) {
      final strain = m.cognitiveStrainIndex;
      return strain.isNaN ? 1.0 : strain;
    }).reduce((a, b) => a + b);

    final avgStrain = sumStrain / recentWindow.length;

    AdaptationDecision decision;

    // حالة إرهاق ذهني أو صعوبة مستمرة
    if (avgStrain >= 0.6) {
      decision = const AdaptationDecision(AdaptationAction.reduceExtraneousLoad, FatigueDetected());
    } else {
      // حالة تدفق واستيعاب سريع (أقل من ثانية ونصف وبدون أخطاء)
      final allCorrect = recentWindow.every((m) => m.isCorrect);
      final isFast = recentWindow.every((m) {
        final latencyMs = m.responseLatency.inMilliseconds < 0 ? 0 : m.responseLatency.inMilliseconds;
        return latencyMs < 2000;
      });
      final allCefrVerified = recentWindow.every((m) => m.isCefrVerified);

      if (allCorrect && isFast && recentWindow.length >= 3) {
        if (!allCefrVerified) {
          decision = const AdaptationDecision(AdaptationAction.maintainFlow, BlockedUnverified());
        } else {
          decision = const AdaptationDecision(AdaptationAction.deepenLinguisticChallenge, ConsistentMastery());
        }
      } else {
        decision = const AdaptationDecision(AdaptationAction.maintainFlow, StableFlow());
      }
    }

    // Hysteresis check: prevent oscillating difficulty
    final lastTime = _lastActionTime[pairKey];
    final lastAct = _lastAction[pairKey];

    if (lastTime != null && lastAct != null && decision.action != lastAct && now.difference(lastTime) < _hysteresisDuration) {
      // If we are changing action, and it's within hysteresis period, block the change.
      return AdaptationDecision(lastAct, const HysteresisCoolDown());
    }

    // Update hysteresis state if decision changes (and is applied)
    if (_lastAction[pairKey] != decision.action) {
      _lastAction[pairKey] = decision.action;
      _lastActionTime[pairKey] = now;
    }

    return decision;
  }

  /// تقييم الحالة الذهنية واتخاذ قرار التكيف التلقائي
  /// Maintains signature for backward compatibility
  AdaptationAction evaluateState({String? targetLanguageCode}) {
    return evaluateDetailedState(targetLanguageCode: targetLanguageCode).action;
  }

  AdaptationDecision evaluateStateDetailed({String? languagePair, DateTime? currentTime}) {
    return evaluateDetailedState(targetLanguageCode: languagePair, currentTime: currentTime);
  }

  void clearSession({String? targetLanguageCode}) {
    if (targetLanguageCode != null) {
      final pairKey = _getPairKey(targetLanguageCode);
      _metricsByPair.remove(pairKey);
      _lastActionTime.remove(pairKey);
      _lastAction.remove(pairKey);
    } else {
      _metricsByPair.clear();
      _lastActionTime.clear();
      _lastAction.clear();
    }
  }
}
