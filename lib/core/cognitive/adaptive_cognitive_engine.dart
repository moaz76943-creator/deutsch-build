import 'cognitive_metric_record.dart';

enum AdaptationAction {
  maintainFlow,
  reduceExtraneousLoad,
  deepenLinguisticChallenge,
}

/// A local heuristic decision, not a proficiency or CEFR assessment.
class AdaptationDecision {
  final AdaptationAction action;
  final String reason;
  const AdaptationDecision(this.action, this.reason);
}

class AdaptiveCognitiveEngine {
  static final AdaptiveCognitiveEngine instance =
      AdaptiveCognitiveEngine._internal();
  AdaptiveCognitiveEngine._internal();

  static const int _windowSize = 5;
  static const int _maxPairWindows = 128;
  final Map<String, List<CognitiveMetricRecord>> _metricsByPair = {};
  final Map<String, AdaptationAction> _lastActionByPair = {};

  /// Malformed observations provide no adaptation evidence.
  void observe(CognitiveMetricRecord record) {
    if (!record.isUsable) return;
    final pair = record.languagePair;
    if (!_metricsByPair.containsKey(pair)) {
      if (_metricsByPair.length >= _maxPairWindows) {
        final evicted = _metricsByPair.keys.first;
        _metricsByPair.remove(evicted);
        _lastActionByPair.remove(evicted);
      }
      _metricsByPair[pair] = <CognitiveMetricRecord>[];
    }
    final window = _metricsByPair[pair]!;
    for (final prior in window) {
      if (prior.sessionEventId == record.sessionEventId) {
        if (prior.contentKey != record.contentKey ||
            prior.isCorrect != record.isCorrect ||
            prior.responseLatency != record.responseLatency ||
            prior.hesitationTaps != record.hesitationTaps ||
            prior.reviewDifficulty != record.reviewDifficulty) {
          throw StateError('Conflicting cognitive event replay');
        }
        return;
      }
    }
    window.add(record);
    if (window.length > _windowSize) window.removeAt(0);
  }

  AdaptationAction evaluateState() => evaluateStateDetailed().action;

  AdaptationDecision evaluateStateDetailed({String languagePair = 'default'}) {
    final window = _metricsByPair[languagePair];
    if (window == null || window.length < 3) {
      return const AdaptationDecision(
          AdaptationAction.maintainFlow, 'Insufficient distinct local observations');
    }

    final strain = window.fold<double>(
            0.0, (sum, record) => sum + record.cognitiveStrainIndex) /
        window.length;
    final previous = _lastActionByPair[languagePair];

    if (strain >= 0.6 ||
        (previous == AdaptationAction.reduceExtraneousLoad && strain > 0.3)) {
      _lastActionByPair[languagePair] = AdaptationAction.reduceExtraneousLoad;
      return const AdaptationDecision(
          AdaptationAction.reduceExtraneousLoad, 'Sustained elevated task load');
    }

    final allCorrect = window.every((r) => r.isCorrect);
    final fast = window.every((r) => r.responseLatency.inMilliseconds < 2000);
    if (allCorrect && fast) {
      _lastActionByPair[languagePair] = AdaptationAction.deepenLinguisticChallenge;
      return const AdaptationDecision(
          AdaptationAction.deepenLinguisticChallenge,
          'Repeated quick, correct local answers; no CEFR inference');
    }

    _lastActionByPair[languagePair] = AdaptationAction.maintainFlow;
    return const AdaptationDecision(
        AdaptationAction.maintainFlow, 'Maintain current challenge');
  }

  void clearSession() {
    _metricsByPair.clear();
    _lastActionByPair.clear();
  }
}
