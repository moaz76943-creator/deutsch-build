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
  final String message;
  const InsufficientData([this.message = 'cold-start']);
}

class StableFlow extends AdaptationReason {
  const StableFlow();
}

class UnverifiedCefr extends AdaptationReason {
  final String message;
  const UnverifiedCefr([this.message = 'blocked: unverified']);
}

class AdaptationDecision {
  final AdaptationAction action;
  final AdaptationReason reason;

  // Backwards compatibility
  String get reasonString {
    if (reason is InsufficientData) return (reason as InsufficientData).message;
    if (reason is UnverifiedCefr) return (reason as UnverifiedCefr).message;
    if (reason is HysteresisCoolDown) return 'Hysteresis';
    return reason.runtimeType.toString();
  }

  const AdaptationDecision(this.action, this.reason);
}

// Helper wrapper to implement `.reason` as a String for cognitive_engine_test.dart compatibility
class DecisionWrapper {
  final AdaptationDecision _decision;

  AdaptationAction get action => _decision.action;
  String get reason => _decision.reasonString;

  DecisionWrapper(this._decision);
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
  static const Duration _hysteresisDuration =
      Duration(minutes: 5); // 5 cooldown

  String _getPairKey(String? targetLanguageCode, String? languagePair) {
    if (languagePair != null && languagePair != 'default') return languagePair;
    return targetLanguageCode ?? _defaultPairKey;
  }

  void observe(CognitiveMetricRecord record) {
    final pairKey = _getPairKey(record.targetLanguageCode, record.languagePair);

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
  AdaptationDecision evaluateDetailedState(
      {String? targetLanguageCode, String? languagePair, DateTime? currentTime}) {
    final pairKey = _getPairKey(targetLanguageCode, languagePair);
    final metrics = _metricsByPair[pairKey] ?? [];

    // Fallback if empty/cold-start
    if (metrics.isEmpty) {
      return const AdaptationDecision(
          AdaptationAction.maintainFlow, InsufficientData());
    }

    final now = currentTime ?? DateTime.now();

    // Determine state from recent metrics (last 5 for actual logic, while preserving 20 for history)
    final recentWindow =
        metrics.length > 5 ? metrics.sublist(metrics.length - 5) : metrics;

    // CEFR Verification check
    final allCefrVerified = recentWindow.every((m) => m.isCefrVerified ?? true);
    if (!allCefrVerified) {
        return const AdaptationDecision(AdaptationAction.maintainFlow, UnverifiedCefr());
    }

    final sumStrain = recentWindow.map((m) {
      final strain = m.cognitiveStrainIndex;
      return strain.isNaN ? 1.0 : strain;
    }).reduce((a, b) => a + b);

    final avgStrain = sumStrain / recentWindow.length;

    AdaptationDecision decision;

    // حالة إرهاق ذهني أو صعوبة مستمرة
    if (avgStrain >= 0.6) {
      decision = const AdaptationDecision(
          AdaptationAction.reduceExtraneousLoad, FatigueDetected());
    } else {
      // حالة تدفق واستيعاب سريع (أقل من ثانية ونصف وبدون أخطاء)
      final allCorrect = recentWindow.every((m) => m.isCorrect);
      final isFast = recentWindow.every((m) {
        // Clamp negative values for speed checking as well, consistent with strain index calculation
        final latency = m.responseLatency.inMilliseconds < 0 ? 0 : m.responseLatency.inMilliseconds;
        return latency >= 0 && latency < 2000;
      });

      if (allCorrect && isFast && recentWindow.length >= 3) {
        decision = const AdaptationDecision(
            AdaptationAction.deepenLinguisticChallenge, ConsistentMastery());
      } else {
        decision = const AdaptationDecision(
            AdaptationAction.maintainFlow, StableFlow());
      }
    }

    // Hysteresis check: prevent oscillating difficulty
    final lastTime = _lastActionTime[pairKey];
    if (lastTime != null && now.difference(lastTime) < _hysteresisDuration) {
      final lastAct = _lastAction[pairKey] ?? AdaptationAction.maintainFlow;
      if (lastAct != decision.action) {
         return AdaptationDecision(lastAct, const HysteresisCoolDown());
      }
    }

    // Update hysteresis state if decision changes
    if (_lastAction[pairKey] != decision.action) {
      _lastAction[pairKey] = decision.action;
      _lastActionTime[pairKey] = now;
    }

    return decision;
  }

  // Wrapper for newer tests that expect `evaluateStateDetailed`
  // Mock decision wrapper for test compat
  DecisionWrapper evaluateStateDetailed({String? languagePair}) {
     final decision = evaluateDetailedState(languagePair: languagePair);
     return DecisionWrapper(decision);
  }

  /// تقييم الحالة الذهنية واتخاذ قرار التكيف التلقائي
  /// Maintains signature for backward compatibility
  AdaptationAction evaluateState({String? targetLanguageCode}) {
    return evaluateDetailedState(targetLanguageCode: targetLanguageCode).action;
  }

  void clearSession({String? targetLanguageCode, String? languagePair}) {
    if (languagePair == 'default') {
      _metricsByPair.remove('default_pair');
      _lastActionTime.remove('default_pair');
      _lastAction.remove('default_pair');
    } else if (languagePair != null) {
      _metricsByPair.remove(languagePair);
      _lastActionTime.remove(languagePair);
      _lastAction.remove(languagePair);
    }
    else if (targetLanguageCode != null) {
      final pairKey = _getPairKey(targetLanguageCode, null);
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
