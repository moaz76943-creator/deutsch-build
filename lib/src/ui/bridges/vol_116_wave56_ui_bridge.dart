import 'dart:async';
import '../../core/content/german_evidentiality_epistemic_modals_engine.dart';

/// State snapshot for UI Bridge Wave 56 (Task 4956).
class Vol116Wave56UiState {
  final List<EvidentialityEpistemicModel> activeExemplars;
  final EvidentialityType? selectedType;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave56UiState({
    required this.activeExemplars,
    this.selectedType,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave56UiState.initial(
      GermanEvidentialityEpistemicModalsEngine engine) {
    return Vol116Wave56UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Evidentiality & Epistemic Modals (Task 4956).
class Vol116Wave56UiBridge {
  final GermanEvidentialityEpistemicModalsEngine _engine;
  final _stateController = StreamController<Vol116Wave56UiState>.broadcast();

  Vol116Wave56UiState _currentState;

  Vol116Wave56UiBridge({GermanEvidentialityEpistemicModalsEngine? engine})
      : _engine = engine ?? GermanEvidentialityEpistemicModalsEngine(),
        _currentState = Vol116Wave56UiState.initial(
            engine ?? GermanEvidentialityEpistemicModalsEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave56UiState> get stateStream => _stateController.stream;
  Vol116Wave56UiState get state => _currentState;

  void filterByType(EvidentialityType? type) {
    List<EvidentialityEpistemicModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByType(type);
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((e) => e.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave56UiState(
      activeExemplars: list,
      selectedType: type,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<EvidentialityEpistemicModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedType != null) {
      list = list.where((e) => e.evidentialityType == _currentState.selectedType).toList();
    }
    _currentState = Vol116Wave56UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave56UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
