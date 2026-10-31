import 'package:flutter/foundation.dart';

import '../domain/cognitive_load_engine.dart';
import '../domain/cognitive_load_models.dart';
import '../domain/pacing_repository.dart';

final class CognitiveLoadAgentState {
  const CognitiveLoadAgentState({
    this.analysis = CognitiveLoadAnalysis.empty,
    this.samples = 0,
    this.isAnalyzing = false,
  });

  final CognitiveLoadAnalysis analysis;
  final int samples;
  final bool isAnalyzing;

  CognitiveState get cognitiveState => analysis.state;
  double get loadScore => analysis.loadScore;
  double get focusIndex => analysis.focusIndex;
  double get comprehensionPace => analysis.comprehensionPace;
  PacingRecommendation get recommendation => analysis.recommendation;

  CognitiveLoadAgentState copyWith({
    CognitiveLoadAnalysis? analysis,
    int? samples,
    bool? isAnalyzing,
  }) {
    return CognitiveLoadAgentState(
      analysis: analysis ?? this.analysis,
      samples: samples ?? this.samples,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }
}

final class CognitiveLoadAgentNotifier extends ChangeNotifier {
  CognitiveLoadAgentNotifier({
    required PacingRepository repository,
    CognitiveLoadEngine engine = const CognitiveLoadEngine(),
    this.analysisWindow = 8,
  })  : _repository = repository,
        _engine = engine {
    if (analysisWindow < 1 || analysisWindow > 32) {
      throw ArgumentError.value(
        analysisWindow,
        'analysisWindow',
        'must be 1..32',
      );
    }
  }

  final PacingRepository _repository;
  final CognitiveLoadEngine _engine;
  final int analysisWindow;

  CognitiveLoadAgentState _state = const CognitiveLoadAgentState();
  Future<void> _serial = Future<void>.value();

  CognitiveLoadAgentState get state => _state;

  Future<void> hydrate() => _enqueue(_recalculate);

  Future<void> recordInteraction(SessionTelemetry telemetry) {
    return _enqueue(() async {
      _setAnalyzing(true);
      await _repository.record(telemetry);
      await _recalculate();
    });
  }

  Future<void> resetSession() {
    return _enqueue(() async {
      _setAnalyzing(true);
      await _repository.clear();
      _state = const CognitiveLoadAgentState();
      notifyListeners();
    });
  }

  Future<void> settle() => _serial;

  Future<void> _recalculate() async {
    final samples = await _repository.recent(limit: analysisWindow);
    final analysis = _engine.analyze(samples);
    _state = CognitiveLoadAgentState(
      analysis: analysis,
      samples: samples.length,
      isAnalyzing: false,
    );
    notifyListeners();
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final next = _serial.then((_) => operation());
    _serial = next.catchError((_) {
      _setAnalyzing(false);
    });
    return next;
  }

  void _setAnalyzing(bool value) {
    if (_state.isAnalyzing == value) return;
    _state = _state.copyWith(isAnalyzing: value);
    notifyListeners();
  }
}
