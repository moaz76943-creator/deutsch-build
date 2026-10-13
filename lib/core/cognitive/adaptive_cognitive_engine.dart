import 'cognitive_metric_record.dart';

enum AdaptationAction {
  maintainFlow,
  reduceExtraneousLoad,
  deepenLinguisticChallenge,
}

class AdaptationDecision {
  final AdaptationAction action;
  final String reason;
  const AdaptationDecision(this.action, this.reason);
}

/// Heuristic learning-flow adjustments only; not CEFR certification.
class AdaptiveCognitiveEngine {
  static final AdaptiveCognitiveEngine instance =
      AdaptiveCognitiveEngine._internal();
  AdaptiveCognitiveEngine._internal();

  static const int _windowSize = 5;
  static const int _maxResidentPairs = 4;
  final Map<String, List<CognitiveMetricRecord>> _metricsByPair = {};
  final Map<String, AdaptationAction> _lastActionByPair = {};

  void observe(CognitiveMetricRecord record) {
    final pair = record.languagePair.trim();
    if (pair.isEmpty ||
        record.sessionEventId.trim().isEmpty ||
        record.contentKey.trim().isEmpty ||
        record.responseLatency.isNegative) {
      return;
    }
    if (!_metricsByPair.containsKey(pair)) {
      if (_metricsByPair.length >= _maxResidentPairs) {
        final oldestPair = _metricsByPair.keys.first;
        _metricsByPair.remove(oldestPair);
        _lastActionByPair.remove(oldestPair);
      }
      _metricsByPair[pair] = <CognitiveMetricRecord>[];
    }
    final metrics = _metricsByPair[pair]!;
    if (metrics.any((m) => m.sessionEventId == record.sessionEventId)) {
      return; // Rapid repeat in this bounded session must not skew difficulty.
    }
    metrics.add(record);
    if (metrics.length > _windowSize) metrics.removeAt(0);
  }

  AdaptationAction evaluateState() => evaluateStateDetailed().action;

  AdaptationDecision evaluateStateDetailed({String languagePair = 'default'}) {
    final metrics = _metricsByPair[languagePair];
    if (metrics == null || metrics.isEmpty) {
      return const AdaptationDecision(
        AdaptationAction.maintainFlow, 'Insufficient local evidence');
    }
    final average = metrics.fold<double>(
          0.0, (sum, record) => sum + record.cognitiveStrainIndex,
        ) / metrics.length;
    final previous = _lastActionByPair[languagePair];

    if (average >= 0.6 ||
        (previous == AdaptationAction.reduceExtraneousLoad && average > 0.3)) {
      _lastActionByPair[languagePair] = AdaptationAction.reduceExtraneousLoad;
      return const AdaptationDecision(
        AdaptationAction.reduceExtraneousLoad, 'Sustained session difficulty');
    }
    final accurate = metrics.length >= 3 &&
        metrics.every((m) => m.isCorrect) &&
        metrics.every((m) => m.responseLatency.inMilliseconds < 2000);
    final action = accurate
        ? AdaptationAction.deepenLinguisticChallenge
        : AdaptationAction.maintainFlow;
    _lastActionByPair[languagePair] = action;
    return AdaptationDecision(
      action,
      accurate ? 'Fast local recall; not a CEFR credential' : 'Maintain flow',
    );
  }

  void clearSession() {
    _metricsByPair.clear();
    _lastActionByPair.clear();
  }
}
