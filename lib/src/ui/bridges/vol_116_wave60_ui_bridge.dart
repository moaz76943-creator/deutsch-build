import 'dart:async';
import '../../core/content/german_temporal_subordination_aspect_engine.dart';

/// State snapshot for UI Bridge Wave 60 (Task 4960).
class Vol116Wave60UiState {
  final List<TemporalSubordinationModel> activeExemplars;
  final TemporalRelationType? selectedRelation;
  final ConsecutioTemporumPair? selectedConsecutio;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave60UiState({
    required this.activeExemplars,
    this.selectedRelation,
    this.selectedConsecutio,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave60UiState.initial(GermanTemporalSubordinationAspectEngine engine) {
    return Vol116Wave60UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Temporal Subordination & Aspectual Anchoring (Task 4960).
class Vol116Wave60UiBridge {
  final GermanTemporalSubordinationAspectEngine _engine;
  final _stateController = StreamController<Vol116Wave60UiState>.broadcast();

  Vol116Wave60UiState _currentState;

  Vol116Wave60UiBridge({GermanTemporalSubordinationAspectEngine? engine})
      : _engine = engine ?? GermanTemporalSubordinationAspectEngine(),
        _currentState = Vol116Wave60UiState.initial(
            engine ?? GermanTemporalSubordinationAspectEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave60UiState> get stateStream => _stateController.stream;
  Vol116Wave60UiState get state => _currentState;

  void filterByRelation(TemporalRelationType? relation) {
    List<TemporalSubordinationModel> list = _engine.catalog;
    if (relation != null) {
      list = _engine.getByRelation(relation);
    }
    if (_currentState.selectedConsecutio != null) {
      list = list.where((t) => t.consecutioPair == _currentState.selectedConsecutio).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((t) => t.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave60UiState(
      activeExemplars: list,
      selectedRelation: relation,
      selectedConsecutio: _currentState.selectedConsecutio,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByConsecutio(ConsecutioTemporumPair? consecutio) {
    List<TemporalSubordinationModel> list = _engine.catalog;
    if (consecutio != null) {
      list = _engine.getByConsecutio(consecutio);
    }
    if (_currentState.selectedRelation != null) {
      list = list.where((t) => t.temporalRelation == _currentState.selectedRelation).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((t) => t.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave60UiState(
      activeExemplars: list,
      selectedRelation: _currentState.selectedRelation,
      selectedConsecutio: consecutio,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<TemporalSubordinationModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedRelation != null) {
      list = list.where((t) => t.temporalRelation == _currentState.selectedRelation).toList();
    }
    if (_currentState.selectedConsecutio != null) {
      list = list.where((t) => t.consecutioPair == _currentState.selectedConsecutio).toList();
    }
    _currentState = Vol116Wave60UiState(
      activeExemplars: list,
      selectedRelation: _currentState.selectedRelation,
      selectedConsecutio: _currentState.selectedConsecutio,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave60UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
