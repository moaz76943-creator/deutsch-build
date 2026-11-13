import 'dart:async';
import '../../core/content/german_passive_paraphrases_engine.dart';

/// State snapshot for UI Bridge Wave 63 (Task 4963).
class Vol116Wave63UiState {
  final List<PassiveParaphraseModel> activeExemplars;
  final PassiveParaphraseType? selectedType;
  final ParaphraseModalNuance? selectedNuance;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave63UiState({
    required this.activeExemplars,
    this.selectedType,
    this.selectedNuance,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave63UiState.initial(GermanPassiveParaphrasesEngine engine) {
    return Vol116Wave63UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Passive Paraphrases & Decausatives (Task 4963).
class Vol116Wave63UiBridge {
  final GermanPassiveParaphrasesEngine _engine;
  final _stateController = StreamController<Vol116Wave63UiState>.broadcast();

  Vol116Wave63UiState _currentState;

  Vol116Wave63UiBridge({GermanPassiveParaphrasesEngine? engine})
      : _engine = engine ?? GermanPassiveParaphrasesEngine(),
        _currentState = Vol116Wave63UiState.initial(
            engine ?? GermanPassiveParaphrasesEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave63UiState> get stateStream => _stateController.stream;
  Vol116Wave63UiState get state => _currentState;

  void filterByType(PassiveParaphraseType? type) {
    List<PassiveParaphraseModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByType(type);
    }
    if (_currentState.selectedNuance != null) {
      list = list.where((p) => p.modalNuance == _currentState.selectedNuance).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((p) => p.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave63UiState(
      activeExemplars: list,
      selectedType: type,
      selectedNuance: _currentState.selectedNuance,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByNuance(ParaphraseModalNuance? nuance) {
    List<PassiveParaphraseModel> list = _engine.catalog;
    if (nuance != null) {
      list = _engine.getByModalNuance(nuance);
    }
    if (_currentState.selectedType != null) {
      list = list.where((p) => p.paraphraseType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((p) => p.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave63UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedNuance: nuance,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<PassiveParaphraseModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedType != null) {
      list = list.where((p) => p.paraphraseType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedNuance != null) {
      list = list.where((p) => p.modalNuance == _currentState.selectedNuance).toList();
    }
    _currentState = Vol116Wave63UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedNuance: _currentState.selectedNuance,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave63UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
