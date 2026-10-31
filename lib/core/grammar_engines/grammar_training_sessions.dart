import 'comparative_superlative_engine.dart';
import 'grammar_engine_models.dart';
import 'konjunktiv_ii_engine.dart';

final class TrainingAttemptResult {
  const TrainingAttemptResult({
    required this.item,
    required this.candidate,
    required this.correct,
    required this.feedbackAr,
  });

  final GrammarTrainingItem item;
  final String candidate;
  final bool correct;
  final String feedbackAr;
}

final class KonjunktivTrainingSession {
  KonjunktivTrainingSession({
    KonjunktivIiEngine engine = const KonjunktivIiEngine(),
    KonjunktivUsage usage = KonjunktivUsage.politeRequest,
    int seed = 1,
  })  : _engine = engine,
        _usage = usage,
        _seed = seed {
    _refresh();
  }

  final KonjunktivIiEngine _engine;
  late GrammarTrainingItem _current;
  KonjunktivUsage _usage;
  int _seed;
  TrainingAttemptResult? _lastAttempt;

  GrammarTrainingItem get current => _current;
  KonjunktivUsage get usage => _usage;
  TrainingAttemptResult? get lastAttempt => _lastAttempt;
  bool get answered => _lastAttempt != null;

  TrainingAttemptResult submit(String candidate) {
    final correct = _current.accepts(candidate);
    final result = TrainingAttemptResult(
      item: _current,
      candidate: candidate.trim(),
      correct: correct,
      feedbackAr: correct
          ? 'إجابة صحيحة. ${_current.explanationAr}'
          : 'الإجابة الصحيحة: ${_current.expectedAnswer}. ${_current.explanationAr}',
    );
    _lastAttempt = result;
    return result;
  }

  GrammarTrainingItem next() {
    _seed += 17;
    _refresh();
    return _current;
  }

  GrammarTrainingItem setUsage(KonjunktivUsage usage) {
    _usage = usage;
    _seed += 7;
    _refresh();
    return _current;
  }

  void _refresh() {
    _current = _engine.generateTrainingItem(
      seed: _seed,
      usage: _usage,
    );
    _lastAttempt = null;
  }
}

final class ComparisonTrainingSession {
  ComparisonTrainingSession({
    ComparativeSuperlativeEngine engine =
        const ComparativeSuperlativeEngine(),
    ComparisonPattern pattern = ComparisonPattern.comparative,
    int seed = 2,
  })  : _engine = engine,
        _pattern = pattern,
        _seed = seed {
    _refresh();
  }

  final ComparativeSuperlativeEngine _engine;
  late GrammarTrainingItem _current;
  ComparisonPattern _pattern;
  int _seed;
  TrainingAttemptResult? _lastAttempt;

  GrammarTrainingItem get current => _current;
  ComparisonPattern get pattern => _pattern;
  TrainingAttemptResult? get lastAttempt => _lastAttempt;
  bool get answered => _lastAttempt != null;

  TrainingAttemptResult submit(String candidate) {
    final correct = _current.accepts(candidate);
    final result = TrainingAttemptResult(
      item: _current,
      candidate: candidate.trim(),
      correct: correct,
      feedbackAr: correct
          ? 'إجابة صحيحة. ${_current.explanationAr}'
          : 'الإجابة الصحيحة: ${_current.expectedAnswer}. ${_current.explanationAr}',
    );
    _lastAttempt = result;
    return result;
  }

  GrammarTrainingItem next() {
    _seed += 19;
    _refresh();
    return _current;
  }

  GrammarTrainingItem setPattern(ComparisonPattern pattern) {
    _pattern = pattern;
    _seed += 5;
    _refresh();
    return _current;
  }

  void _refresh() {
    _current = _engine.generateTrainingItem(
      seed: _seed,
      pattern: _pattern,
    );
    _lastAttempt = null;
  }
}
