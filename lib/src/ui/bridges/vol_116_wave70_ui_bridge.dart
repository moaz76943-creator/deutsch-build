import 'dart:async';
import '../../core/content/german_adverbial_nominalization_compression_engine.dart';

/// State snapshot for UI Bridge Wave 70 (Task 4970).
class Vol116Wave70UiState {
  final List<AdverbialNominalizationModel> activeExemplars;
  final AdverbialCompressionRelation? selectedRelation;
  final PrepositionGovernedCase? selectedCase;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave70UiState({
    required this.activeExemplars,
    this.selectedRelation,
    this.selectedCase,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave70UiState.initial(
      GermanAdverbialNominalizationCompressionEngine engine) {
    return Vol116Wave70UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Adverbial-to-Nominal Compression (Task 4970).
class Vol116Wave70UiBridge {
  final GermanAdverbialNominalizationCompressionEngine _engine;
  final _stateController = StreamController<Vol116Wave70UiState>.broadcast();

  Vol116Wave70UiState _currentState;

  Vol116Wave70UiBridge({GermanAdverbialNominalizationCompressionEngine? engine})
      : _engine = engine ?? GermanAdverbialNominalizationCompressionEngine(),
        _currentState = Vol116Wave70UiState.initial(
            engine ?? GermanAdverbialNominalizationCompressionEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave70UiState> get stateStream => _stateController.stream;
  Vol116Wave70UiState get state => _currentState;

  void filterByRelation(AdverbialCompressionRelation? relation) {
    List<AdverbialNominalizationModel> list = _engine.catalog;
    if (relation != null) {
      list = _engine.getByRelation(relation);
    }
    if (_currentState.selectedCase != null) {
      list = list.where((m) => m.governedCase == _currentState.selectedCase).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((m) => m.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave70UiState(
      activeExemplars: list,
      selectedRelation: relation,
      selectedCase: _currentState.selectedCase,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByCase(PrepositionGovernedCase? governedCase) {
    List<AdverbialNominalizationModel> list = _engine.catalog;
    if (governedCase != null) {
      list = _engine.getByCase(governedCase);
    }
    if (_currentState.selectedRelation != null) {
      list = list.where((m) => m.relation == _currentState.selectedRelation).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((m) => m.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave70UiState(
      activeExemplars: list,
      selectedRelation: _currentState.selectedRelation,
      selectedCase: governedCase,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<AdverbialNominalizationModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedRelation != null) {
      list = list.where((m) => m.relation == _currentState.selectedRelation).toList();
    }
    if (_currentState.selectedCase != null) {
      list = list.where((m) => m.governedCase == _currentState.selectedCase).toList();
    }
    _currentState = Vol116Wave70UiState(
      activeExemplars: list,
      selectedRelation: _currentState.selectedRelation,
      selectedCase: _currentState.selectedCase,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave70UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
