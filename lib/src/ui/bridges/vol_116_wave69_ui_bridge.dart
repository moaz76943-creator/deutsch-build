import 'dart:async';
import '../../core/content/german_partitive_genitive_apposition_engine.dart';

/// State snapshot for UI Bridge Wave 69 (Task 4969).
class Vol116Wave69UiState {
  final List<PartitiveAppositionModel> activeExemplars;
  final PartitiveAppositionCategory? selectedCategory;
  final AdjectiveMeasureCaseGovernance? selectedGovernance;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave69UiState({
    required this.activeExemplars,
    this.selectedCategory,
    this.selectedGovernance,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave69UiState.initial(GermanPartitiveGenitiveAppositionEngine engine) {
    return Vol116Wave69UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Partitive Genitive & Appositions (Task 4969).
class Vol116Wave69UiBridge {
  final GermanPartitiveGenitiveAppositionEngine _engine;
  final _stateController = StreamController<Vol116Wave69UiState>.broadcast();

  Vol116Wave69UiState _currentState;

  Vol116Wave69UiBridge({GermanPartitiveGenitiveAppositionEngine? engine})
      : _engine = engine ?? GermanPartitiveGenitiveAppositionEngine(),
        _currentState = Vol116Wave69UiState.initial(
            engine ?? GermanPartitiveGenitiveAppositionEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave69UiState> get stateStream => _stateController.stream;
  Vol116Wave69UiState get state => _currentState;

  void filterByCategory(PartitiveAppositionCategory? category) {
    List<PartitiveAppositionModel> list = _engine.catalog;
    if (category != null) {
      list = _engine.getByCategory(category);
    }
    if (_currentState.selectedGovernance != null) {
      list = list.where((p) => p.caseGovernance == _currentState.selectedGovernance).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((p) => p.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave69UiState(
      activeExemplars: list,
      selectedCategory: category,
      selectedGovernance: _currentState.selectedGovernance,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByGovernance(AdjectiveMeasureCaseGovernance? gov) {
    List<PartitiveAppositionModel> list = _engine.catalog;
    if (gov != null) {
      list = _engine.getByGovernance(gov);
    }
    if (_currentState.selectedCategory != null) {
      list = list.where((p) => p.category == _currentState.selectedCategory).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((p) => p.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave69UiState(
      activeExemplars: list,
      selectedCategory: _currentState.selectedCategory,
      selectedGovernance: gov,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<PartitiveAppositionModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedCategory != null) {
      list = list.where((p) => p.category == _currentState.selectedCategory).toList();
    }
    if (_currentState.selectedGovernance != null) {
      list = list.where((p) => p.caseGovernance == _currentState.selectedGovernance).toList();
    }
    _currentState = Vol116Wave69UiState(
      activeExemplars: list,
      selectedCategory: _currentState.selectedCategory,
      selectedGovernance: _currentState.selectedGovernance,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave69UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
