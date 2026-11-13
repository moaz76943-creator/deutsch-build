import 'dart:async';
import '../../core/content/german_participial_attributes_gerundive_engine.dart';

/// State snapshot for UI Bridge Wave 61 (Task 4961).
class Vol116Wave61UiState {
  final List<ParticipialAttributeModel> activeExemplars;
  final ParticipialConstructionType? selectedType;
  final ParticipialCaseAndGender? selectedCaseGender;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave61UiState({
    required this.activeExemplars,
    this.selectedType,
    this.selectedCaseGender,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave61UiState.initial(GermanParticipialAttributesGerundiveEngine engine) {
    return Vol116Wave61UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Extended Participles & Gerundives (Task 4961).
class Vol116Wave61UiBridge {
  final GermanParticipialAttributesGerundiveEngine _engine;
  final _stateController = StreamController<Vol116Wave61UiState>.broadcast();

  Vol116Wave61UiState _currentState;

  Vol116Wave61UiBridge({GermanParticipialAttributesGerundiveEngine? engine})
      : _engine = engine ?? GermanParticipialAttributesGerundiveEngine(),
        _currentState = Vol116Wave61UiState.initial(
            engine ?? GermanParticipialAttributesGerundiveEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave61UiState> get stateStream => _stateController.stream;
  Vol116Wave61UiState get state => _currentState;

  void filterByType(ParticipialConstructionType? type) {
    List<ParticipialAttributeModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByType(type);
    }
    if (_currentState.selectedCaseGender != null) {
      list = list.where((p) => p.caseAndGender == _currentState.selectedCaseGender).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((p) => p.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave61UiState(
      activeExemplars: list,
      selectedType: type,
      selectedCaseGender: _currentState.selectedCaseGender,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByCaseGender(ParticipialCaseAndGender? cg) {
    List<ParticipialAttributeModel> list = _engine.catalog;
    if (cg != null) {
      list = _engine.getByCaseAndGender(cg);
    }
    if (_currentState.selectedType != null) {
      list = list.where((p) => p.constructionType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((p) => p.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave61UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedCaseGender: cg,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<ParticipialAttributeModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedType != null) {
      list = list.where((p) => p.constructionType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedCaseGender != null) {
      list = list.where((p) => p.caseAndGender == _currentState.selectedCaseGender).toList();
    }
    _currentState = Vol116Wave61UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedCaseGender: _currentState.selectedCaseGender,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave61UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
