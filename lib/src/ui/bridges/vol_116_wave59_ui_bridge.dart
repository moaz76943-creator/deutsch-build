import 'dart:async';
import '../../core/content/german_cleft_sentences_engine.dart';

/// State snapshot for UI Bridge Wave 59 (Task 4959).
class Vol116Wave59UiState {
  final List<CleftSentenceModel> activeExemplars;
  final CleftConstructionType? selectedType;
  final CleftFocusCategory? selectedCategory;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave59UiState({
    required this.activeExemplars,
    this.selectedType,
    this.selectedCategory,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave59UiState.initial(GermanCleftSentencesEngine engine) {
    return Vol116Wave59UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Cleft and Pseudo-Cleft Constructions (Task 4959).
class Vol116Wave59UiBridge {
  final GermanCleftSentencesEngine _engine;
  final _stateController = StreamController<Vol116Wave59UiState>.broadcast();

  Vol116Wave59UiState _currentState;

  Vol116Wave59UiBridge({GermanCleftSentencesEngine? engine})
      : _engine = engine ?? GermanCleftSentencesEngine(),
        _currentState = Vol116Wave59UiState.initial(
            engine ?? GermanCleftSentencesEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave59UiState> get stateStream => _stateController.stream;
  Vol116Wave59UiState get state => _currentState;

  void filterByType(CleftConstructionType? type) {
    List<CleftSentenceModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByType(type);
    }
    if (_currentState.selectedCategory != null) {
      list = list.where((c) => c.focusCategory == _currentState.selectedCategory).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((c) => c.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave59UiState(
      activeExemplars: list,
      selectedType: type,
      selectedCategory: _currentState.selectedCategory,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByCategory(CleftFocusCategory? category) {
    List<CleftSentenceModel> list = _engine.catalog;
    if (category != null) {
      list = _engine.getByFocusCategory(category);
    }
    if (_currentState.selectedType != null) {
      list = list.where((c) => c.constructionType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((c) => c.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave59UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedCategory: category,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<CleftSentenceModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedType != null) {
      list = list.where((c) => c.constructionType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedCategory != null) {
      list = list.where((c) => c.focusCategory == _currentState.selectedCategory).toList();
    }
    _currentState = Vol116Wave59UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedCategory: _currentState.selectedCategory,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave59UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
