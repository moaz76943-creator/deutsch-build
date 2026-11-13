import 'dart:async';
import '../../core/content/german_prepositional_correlates_es_engine.dart';

/// State snapshot for UI Bridge Wave 67 (Task 4967).
class Vol116Wave67UiState {
  final List<PrepositionalCorrelateModel> activeExemplars;
  final CorrelateCategory? selectedCategory;
  final EmbeddedClauseType? selectedEmbeddedType;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave67UiState({
    required this.activeExemplars,
    this.selectedCategory,
    this.selectedEmbeddedType,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave67UiState.initial(GermanPrepositionalCorrelatesEsEngine engine) {
    return Vol116Wave67UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Prepositional Correlates & Expletive "es" (Task 4967).
class Vol116Wave67UiBridge {
  final GermanPrepositionalCorrelatesEsEngine _engine;
  final _stateController = StreamController<Vol116Wave67UiState>.broadcast();

  Vol116Wave67UiState _currentState;

  Vol116Wave67UiBridge({GermanPrepositionalCorrelatesEsEngine? engine})
      : _engine = engine ?? GermanPrepositionalCorrelatesEsEngine(),
        _currentState = Vol116Wave67UiState.initial(
            engine ?? GermanPrepositionalCorrelatesEsEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave67UiState> get stateStream => _stateController.stream;
  Vol116Wave67UiState get state => _currentState;

  void filterByCategory(CorrelateCategory? category) {
    List<PrepositionalCorrelateModel> list = _engine.catalog;
    if (category != null) {
      list = _engine.getByCategory(category);
    }
    if (_currentState.selectedEmbeddedType != null) {
      list = list.where((e) => e.embeddedClauseType == _currentState.selectedEmbeddedType).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((e) => e.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave67UiState(
      activeExemplars: list,
      selectedCategory: category,
      selectedEmbeddedType: _currentState.selectedEmbeddedType,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByEmbeddedType(EmbeddedClauseType? type) {
    List<PrepositionalCorrelateModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByEmbeddedType(type);
    }
    if (_currentState.selectedCategory != null) {
      list = list.where((e) => e.category == _currentState.selectedCategory).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((e) => e.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave67UiState(
      activeExemplars: list,
      selectedCategory: _currentState.selectedCategory,
      selectedEmbeddedType: type,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<PrepositionalCorrelateModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedCategory != null) {
      list = list.where((e) => e.category == _currentState.selectedCategory).toList();
    }
    if (_currentState.selectedEmbeddedType != null) {
      list = list.where((e) => e.embeddedClauseType == _currentState.selectedEmbeddedType).toList();
    }
    _currentState = Vol116Wave67UiState(
      activeExemplars: list,
      selectedCategory: _currentState.selectedCategory,
      selectedEmbeddedType: _currentState.selectedEmbeddedType,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave67UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
