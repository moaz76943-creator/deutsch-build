import 'cognitive_metric_record.dart';

enum AdaptationAction {
  maintainFlow,       // المتعلم في حالة تدفق ممتازة (استمر بنفس الوتيرة)
  reduceExtraneousLoad, // إرهاق أو صعوبة (تبسيط الشاشة وتهدئة الوتيرة)
  deepenLinguisticChallenge, // تمكن وسرعة فائقة (عرض تفاصيل لسانية أعمق)
}

enum AdaptationReason {
  coldStart,
  sustainedStrain,
  excellentFlow,
  recovering,
  defaultFlow,
}

class AdaptationDecision {
  final AdaptationAction action;
  final AdaptationReason reason;

  const AdaptationDecision(this.action, this.reason);
}

class AdaptiveCognitiveEngine {
  static final AdaptiveCognitiveEngine instance = AdaptiveCognitiveEngine._internal();
  AdaptiveCognitiveEngine._internal();

  final Map<String, List<CognitiveMetricRecord>> _metricsHistory = {};
  static const int _windowSize = 5; // مراقبة آخر 5 تفاعلات

  void observe(CognitiveMetricRecord record, {String languagePairKey = 'default'}) {
    // Drop malformed/extreme records (e.g. latency > 1 hour)
    if (record.responseLatency.inHours > 1) {
      return;
    }

    final pairKey = record.languagePairKey != 'default' ? record.languagePairKey : languagePairKey;
    _metricsHistory.putIfAbsent(pairKey, () => []);
    _metricsHistory[pairKey]!.add(record);

    if (_metricsHistory[pairKey]!.length > _windowSize) {
      _metricsHistory[pairKey]!.removeAt(0);
    }
  }

  final Map<String, AdaptationAction> _previousActions = {};

  AdaptationDecision evaluateDecision({String languagePairKey = 'default'}) {
    final recentMetrics = _metricsHistory[languagePairKey] ?? [];

    if (recentMetrics.isEmpty) {
      _previousActions[languagePairKey] = AdaptationAction.maintainFlow;
      return const AdaptationDecision(AdaptationAction.maintainFlow, AdaptationReason.coldStart);
    }

    final avgStrain = recentMetrics
            .map((m) => m.cognitiveStrainIndex)
            .reduce((a, b) => a + b) /
        recentMetrics.length;

    final prevAction = _previousActions[languagePairKey] ?? AdaptationAction.maintainFlow;

    // Hysteresis: If we were reducing load, require significantly better metrics to escape.
    if (prevAction == AdaptationAction.reduceExtraneousLoad) {
      if (avgStrain < 0.3) {
        // Recovered
        _previousActions[languagePairKey] = AdaptationAction.maintainFlow;
        return const AdaptationDecision(AdaptationAction.maintainFlow, AdaptationReason.recovering);
      }
      return const AdaptationDecision(AdaptationAction.reduceExtraneousLoad, AdaptationReason.sustainedStrain);
    }

    // حالة إرهاق ذهني أو صعوبة مستمرة
    if (avgStrain >= 0.6) {
      _previousActions[languagePairKey] = AdaptationAction.reduceExtraneousLoad;
      return const AdaptationDecision(AdaptationAction.reduceExtraneousLoad, AdaptationReason.sustainedStrain);
    }

    // حالة تدفق واستيعاب سريع (أقل من ثانية ونصف وبدون أخطاء)
    final allCorrect = recentMetrics.every((m) => m.isCorrect);
    final isFast = recentMetrics.every((m) => m.responseLatency.inMilliseconds < 2000);

    // Any signs of struggle drop deepened challenge immediately (Hysteresis for Deepen)
    if (prevAction == AdaptationAction.deepenLinguisticChallenge && (!allCorrect || !isFast || avgStrain > 0.1)) {
       _previousActions[languagePairKey] = AdaptationAction.maintainFlow;
       return const AdaptationDecision(AdaptationAction.maintainFlow, AdaptationReason.recovering);
    }

    if (allCorrect && isFast && recentMetrics.length >= 3) {
      _previousActions[languagePairKey] = AdaptationAction.deepenLinguisticChallenge;
      return const AdaptationDecision(AdaptationAction.deepenLinguisticChallenge, AdaptationReason.excellentFlow);
    }

    _previousActions[languagePairKey] = AdaptationAction.maintainFlow;
    return const AdaptationDecision(AdaptationAction.maintainFlow, AdaptationReason.defaultFlow);
  }

  /// تقييم الحالة الذهنية واتخاذ قرار التكيف التلقائي
  AdaptationAction evaluateState({String languagePairKey = 'default'}) {
    // For backward compatibility
    return evaluateDecision(languagePairKey: languagePairKey).action;
  }

  void clearSession({String languagePairKey = 'default'}) {
    if (languagePairKey == 'default' && _metricsHistory.keys.length == 1 && _metricsHistory.containsKey('default')) {
       _metricsHistory.clear();
    } else {
       _metricsHistory.remove(languagePairKey);
    }
  }
}
