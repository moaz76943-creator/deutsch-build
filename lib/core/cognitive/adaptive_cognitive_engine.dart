import 'cognitive_metric_record.dart';

enum AdaptationAction {
  maintainFlow,       // المتعلم في حالة تدفق ممتازة (استمر بنفس الوتيرة)
  reduceExtraneousLoad, // إرهاق أو صعوبة (تبسيط الشاشة وتهدئة الوتيرة)
  deepenLinguisticChallenge, // تمكن وسرعة فائقة (عرض تفاصيل لسانية أعمق)
}

class AdaptiveCognitiveEngine {
  static final AdaptiveCognitiveEngine instance = AdaptiveCognitiveEngine._internal();
  AdaptiveCognitiveEngine._internal();

  final List<CognitiveMetricRecord> _recentMetrics = [];
  static const int _windowSize = 5; // مراقبة آخر 5 تفاعلات

  void observe(CognitiveMetricRecord record) {
    _recentMetrics.add(record);
    if (_recentMetrics.length > _windowSize) {
      _recentMetrics.removeAt(0);
    }
  }

  /// تقييم الحالة الذهنية واتخاذ قرار التكيف التلقائي
  AdaptationAction evaluateState() {
    if (_recentMetrics.isEmpty) return AdaptationAction.maintainFlow;

    final avgStrain = _recentMetrics
            .map((m) => m.cognitiveStrainIndex)
            .reduce((a, b) => a + b) /
        _recentMetrics.length;

    // حالة إرهاق ذهني أو صعوبة مستمرة
    if (avgStrain >= 0.6) {
      return AdaptationAction.reduceExtraneousLoad;
    }

    // حالة تدفق واستيعاب سريع (أقل من ثانية ونصف وبدون أخطاء)
    final allCorrect = _recentMetrics.every((m) => m.isCorrect);
    final isFast = _recentMetrics.every((m) => m.responseLatency.inMilliseconds < 2000);

    if (allCorrect && isFast && _recentMetrics.length >= 3) {
      return AdaptationAction.deepenLinguisticChallenge;
    }

    return AdaptationAction.maintainFlow;
  }

  void clearSession() {
    _recentMetrics.clear();
  }
}
