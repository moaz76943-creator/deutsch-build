import 'dart:async';
import '../../core/content/german_information_structure_focus_engine.dart';

/// State snapshot for UI Bridge Wave 57 (Task 4957).
class Vol116Wave57UiState {
  final List<InformationStructureModel> activeExemplars;
  final InformationPackagingType? selectedType;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave57UiState({
    required this.activeExemplars,
    this.selectedType,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave57UiState.initial(
      GermanInformationStructureFocusEngine engine) {
    return Vol116Wave57UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Information Structure & Focus Partitioning (Task 4957).
class Vol116Wave57UiBridge {
  final GermanInformationStructureFocusEngine _engine;
  final _stateController = StreamController<Vol116Wave57UiState>.broadcast();

  Vol116Wave57UiState _currentState;

  Vol116Wave57UiBridge({GermanInformationStructureFocusEngine? engine})
      : _engine = engine ?? GermanInformationStructureFocusEngine(),
        _currentState = Vol116Wave57UiState.initial(
            engine ?? GermanInformationStructureFocusEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave57UiState> get stateStream => _stateController.stream;
  Vol116Wave57UiState get state => _currentState;

  void filterByType(InformationPackagingType? type) {
    List<InformationStructureModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByType(type);
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((e) => e.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave57UiState(
      activeExemplars: list,
      selectedType: type,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<InformationStructureModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedType != null) {
      list = list.where((e) => e.packagingType == _currentState.selectedType).toList();
    }
    _currentState = Vol116Wave57UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave57UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
