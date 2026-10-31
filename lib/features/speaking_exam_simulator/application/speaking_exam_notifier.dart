import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/speaking_exam_models.dart';
import '../domain/speaking_exam_repository.dart';

final class SpeakingExamNotifier extends ChangeNotifier {
  SpeakingExamNotifier(this._repository);

  final SpeakingExamRepository _repository;

  List<SpeakingExamScenario> _scenarios =
      const <SpeakingExamScenario>[];
  int _scenarioIndex = 0;
  int _currentPhaseIndex = 0;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isCompleted = false;
  bool _isLoading = false;
  DebateStance? _selectedStance;
  ExamProvider? _providerFilter;
  ExamLevel? _levelFilter;
  Timer? _ticker;
  int _requestGeneration = 0;

  List<SpeakingExamScenario> get scenarios =>
      List<SpeakingExamScenario>.unmodifiable(_scenarios);
  int get scenarioIndex => _scenarioIndex;
  int get currentPhaseIndex => _currentPhaseIndex;
  int get secondsRemaining => _secondsRemaining;
  bool get isRunning => _isRunning;
  bool get isCompleted => _isCompleted;
  bool get isLoading => _isLoading;
  DebateStance? get selectedStance => _selectedStance;
  ExamProvider? get providerFilter => _providerFilter;
  ExamLevel? get levelFilter => _levelFilter;

  SpeakingExamScenario? get currentScenario {
    if (_scenarios.isEmpty || _scenarioIndex >= _scenarios.length) {
      return null;
    }
    return _scenarios[_scenarioIndex];
  }

  SpeakingPhaseConfig? get currentPhase {
    final scenario = currentScenario;
    if (scenario == null ||
        _currentPhaseIndex >= scenario.phases.length) {
      return null;
    }
    return scenario.phases[_currentPhaseIndex];
  }

  double get phaseProgress {
    final phase = currentPhase;
    if (phase == null || phase.duration.inSeconds <= 0) return 0;
    final elapsed =
        phase.duration.inSeconds - _secondsRemaining;
    return (elapsed / phase.duration.inSeconds).clamp(0.0, 1.0).toDouble();
  }

  String get formattedRemaining {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return mm + ':' + ss;
  }

  Future<void> load({
    ExamProvider? provider,
    ExamLevel? level,
  }) async {
    final generation = ++_requestGeneration;
    pauseTimer(notify: false);
    _isLoading = true;
    notifyListeners();

    final loaded = await _repository.getScenarios(
      provider: provider,
      level: level,
    );
    if (generation != _requestGeneration) return;

    _scenarios = List<SpeakingExamScenario>.unmodifiable(loaded);
    _providerFilter = provider;
    _levelFilter = level;
    _scenarioIndex = 0;
    _resetExamState();
    _isLoading = false;
    notifyListeners();
  }

  void startTimer() {
    if (_isCompleted || currentPhase == null || _isRunning) return;

    _isRunning = true;
    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => advanceClock(const Duration(seconds: 1)),
    );
    notifyListeners();
  }

  void pauseTimer({bool notify = true}) {
    _ticker?.cancel();
    _ticker = null;
    final changed = _isRunning;
    _isRunning = false;
    if (notify && changed) notifyListeners();
  }

  void resetCurrentPhase() {
    pauseTimer(notify: false);
    final phase = currentPhase;
    _secondsRemaining = phase?.duration.inSeconds ?? 0;
    _isCompleted = false;
    notifyListeners();
  }

  void advanceClock(Duration elapsed) {
    if (_isCompleted || currentPhase == null) return;

    var remainingElapsed = elapsed.inSeconds;
    if (remainingElapsed <= 0) return;

    while (remainingElapsed > 0 && !_isCompleted) {
      if (remainingElapsed < _secondsRemaining) {
        _secondsRemaining -= remainingElapsed;
        remainingElapsed = 0;
        break;
      }

      remainingElapsed -= _secondsRemaining;
      _advancePhaseInternal();
    }

    notifyListeners();
  }

  void nextPhase() {
    if (_isCompleted || currentScenario == null) return;
    _advancePhaseInternal();
    notifyListeners();
  }

  void previousPhase() {
    final scenario = currentScenario;
    if (scenario == null || _currentPhaseIndex <= 0) return;

    _currentPhaseIndex--;
    _isCompleted = false;
    _secondsRemaining =
        scenario.phases[_currentPhaseIndex].duration.inSeconds;
    notifyListeners();
  }

  void selectStance(DebateStance stance) {
    if (_selectedStance == stance) return;
    _selectedStance = stance;
    notifyListeners();
  }

  void nextScenario() {
    if (_scenarios.isEmpty) return;

    pauseTimer(notify: false);
    _scenarioIndex = (_scenarioIndex + 1) % _scenarios.length;
    _resetExamState();
    notifyListeners();
  }

  Future<void> applyFilter({
    ExamProvider? provider,
    ExamLevel? level,
  }) async {
    await load(provider: provider, level: level);
  }

  void _advancePhaseInternal() {
    final scenario = currentScenario;
    if (scenario == null) return;

    if (_currentPhaseIndex >= scenario.phases.length - 1) {
      pauseTimer(notify: false);
      _secondsRemaining = 0;
      _isCompleted = true;
      return;
    }

    _currentPhaseIndex++;
    _secondsRemaining =
        scenario.phases[_currentPhaseIndex].duration.inSeconds;
  }

  void _resetExamState() {
    _currentPhaseIndex = 0;
    _selectedStance = null;
    _isCompleted = false;
    _isRunning = false;
    _ticker?.cancel();
    _ticker = null;
    _secondsRemaining =
        currentPhase?.duration.inSeconds ?? 0;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
