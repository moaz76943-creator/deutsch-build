import 'dart:async';
import '../../core/content/german_adjective_noun_valency_engine.dart';

/// State snapshot for UI Bridge Wave 71 (Task 4971).
class Vol116Wave71UiState {
  final List<AdjectiveNounValencyModel> activeExemplars;
  final ValencyGovernanceCategory? selectedCategory;
  final GovernedCaseOrPreposition? selectedRection;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave71UiState({
    required this.activeExemplars,
    this.selectedCategory,
    this.selectedRection,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave71UiState.initial(GermanAdjectiveNounValencyEngine engine) {
    return Vol116Wave71UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Adjective & Noun Valency Governance (Task 4971).
class Vol116Wave71UiBridge {
  final GermanAdjectiveNounValencyEngine _engine;
  final _stateController = StreamController<Vol116Wave71UiState>.broadcast();

  Vol116Wave71UiState _currentState;

  Vol116Wave71UiBridge({GermanAdjectiveNounValencyEngine? engine})
      : _engine = engine ?? GermanAdjectiveNounValencyEngine(),
        _currentState = Vol116Wave71UiState.initial(
            engine ?? GermanAdjectiveNounValencyEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave71UiState> get stateStream => _stateController.stream;
  Vol116Wave71UiState get state => _currentState;

  void filterByCategory(ValencyGovernanceCategory? category) {
    List<AdjectiveNounValencyModel> list = _engine.catalog;
    if (category != null) {
      list = _engine.getByCategory(category);
    }
    if (_currentState.selectedRection != null) {
      list = list.where((v) => v.rection == _currentState.selectedRection).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((v) => v.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave71UiState(
      activeExemplars: list,
      selectedCategory: category,
      selectedRection: _currentState.selectedRection,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByRection(GovernedCaseOrPreposition? rection) {
    List<AdjectiveNounValencyModel> list = _engine.catalog;
    if (rection != null) {
      list = _engine.getByRection(rection);
    }
    if (_currentState.selectedCategory != null) {
      list = list.where((v) => v.category == _currentState.selectedCategory).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((v) => v.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave71UiState(
      activeExemplars: list,
      selectedCategory: _currentState.selectedCategory,
      selectedRection: rection,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<AdjectiveNounValencyModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedCategory != null) {
      list = list.where((v) => v.category == _currentState.selectedCategory).toList();
    }
    if (_currentState.selectedRection != null) {
      list = list.where((v) => v.rection == _currentState.selectedRection).toList();
    }
    _currentState = Vol116Wave71UiState(
      activeExemplars: list,
      selectedCategory: _currentState.selectedCategory,
      selectedRection: _currentState.selectedRection,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave71UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
