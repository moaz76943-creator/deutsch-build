import 'cognitive_metric_record.dart';

enum AdaptationAction {
  maintainFlow,       // المتعلم في حالة تدفق ممتازة (استمر بنفس الوتيرة)
  reduceExtraneousLoad, // إرهاق أو صعوبة (تبسيط الشاشة وتهدئة الوتيرة)
  deepenLinguisticChallenge, // تمكن وسرعة فائقة (عرض تفاصيل لسانية أعمق)
}

class AdaptationDecision {
  final AdaptationAction action;
  final String reason;

  const AdaptationDecision(this.action, this.reason);
}

class AdaptiveCognitiveEngine {
  static final AdaptiveCognitiveEngine instance = AdaptiveCognitiveEngine._internal();
  AdaptiveCognitiveEngine._internal();

  final Map<String, List<CognitiveMetricRecord>> _metricsByPair = {};
  final Map<String, AdaptationAction> _lastActionByPair = {};

  static const int _windowSize = 5; // مراقبة آخر 5 تفاعلات

  void observe(CognitiveMetricRecord record) {
    final pair = record.languagePair;
    if (!_metricsByPair.containsKey(pair)) {
      _metricsByPair[pair] = [];
    }

    final metrics = _metricsByPair[pair]!;
    metrics.add(record);
    if (metrics.length > _windowSize) {
      metrics.removeAt(0);
    }
  }

  /// تقييم الحالة الذهنية واتخاذ قرار التكيف التلقائي (Backward compatibility)
  AdaptationAction evaluateState() {
    return evaluateStateDetailed().action;
  }

  AdaptationDecision evaluateStateDetailed({String languagePair = 'default'}) {
    final metrics = _metricsByPair[languagePair] ?? [];

    if (metrics.isEmpty) {
      return const AdaptationDecision(AdaptationAction.maintainFlow, 'Safe cold-start: No metrics available');
    }

    final avgStrain = metrics
            .map((m) => m.cognitiveStrainIndex)
            .reduce((a, b) => a + b) /
        metrics.length;

    final lastAction = _lastActionByPair[languagePair];

    // Hysteresis: Stay in reduced load until strain drops sufficiently
    if (lastAction == AdaptationAction.reduceExtraneousLoad && avgStrain > 0.3) {
       _lastActionByPair[languagePair] = AdaptationAction.reduceExtraneousLoad;
       return const AdaptationDecision(AdaptationAction.reduceExtraneousLoad, 'Hysteresis: Recovering from high cognitive strain');
    }

    // حالة إرهاق ذهني أو صعوبة مستمرة
    if (avgStrain >= 0.6) {
      _lastActionByPair[languagePair] = AdaptationAction.reduceExtraneousLoad;
      return const AdaptationDecision(AdaptationAction.reduceExtraneousLoad, 'High average strain detected');
    }

    // حالة تدفق واستيعاب سريع (أقل من ثانية ونصف وبدون أخطاء)
    final allCorrect = metrics.every((m) => m.isCorrect);

    // Sanitize negative latencies just in case
    final isFast = metrics.every((m) {
        int ms = m.responseLatency.inMilliseconds;
        if (ms < 0) ms = 0;
        return ms < 2000;
    });

    final allVerified = metrics.every((m) => m.isCefrVerified);

    if (allCorrect && isFast && metrics.length >= 3) {
      if (allVerified) {
        _lastActionByPair[languagePair] = AdaptationAction.deepenLinguisticChallenge;
        return const AdaptationDecision(AdaptationAction.deepenLinguisticChallenge, 'Fast, correct, and verified CEFR responses');
      } else {
        _lastActionByPair[languagePair] = AdaptationAction.maintainFlow;
        return const AdaptationDecision(AdaptationAction.maintainFlow, 'Challenge deepen blocked: unverified CEFR');
      }
    }

    _lastActionByPair[languagePair] = AdaptationAction.maintainFlow;
    return const AdaptationDecision(AdaptationAction.maintainFlow, 'Maintaining normal flow');
  }

  void clearSession() {
    _metricsByPair.clear();
    _lastActionByPair.clear();
  }
}
