import 'dart:async';
import '../../core/content/german_nominal_style_fvg_engine.dart';

/// State snapshot for UI Bridge Wave 64 (Task 4964).
class Vol116Wave64UiState {
  final List<NominalStyleFvgModel> activeExemplars;
  final FvgAktionsartType? selectedAktionsart;
  final PrepositionalRektionCase? selectedRektion;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave64UiState({
    required this.activeExemplars,
    this.selectedAktionsart,
    this.selectedRektion,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave64UiState.initial(GermanNominalStyleFvgEngine engine) {
    return Vol116Wave64UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Nominal Style & FVG Deconstruction (Task 4964).
class Vol116Wave64UiBridge {
  final GermanNominalStyleFvgEngine _engine;
  final _stateController = StreamController<Vol116Wave64UiState>.broadcast();

  Vol116Wave64UiState _currentState;

  Vol116Wave64UiBridge({GermanNominalStyleFvgEngine? engine})
      : _engine = engine ?? GermanNominalStyleFvgEngine(),
        _currentState = Vol116Wave64UiState.initial(
            engine ?? GermanNominalStyleFvgEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave64UiState> get stateStream => _stateController.stream;
  Vol116Wave64UiState get state => _currentState;

  void filterByAktionsart(FvgAktionsartType? type) {
    List<NominalStyleFvgModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByAktionsart(type);
    }
    if (_currentState.selectedRektion != null) {
      list = list.where((f) => f.rektionCase == _currentState.selectedRektion).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((f) => f.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave64UiState(
      activeExemplars: list,
      selectedAktionsart: type,
      selectedRektion: _currentState.selectedRektion,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByRektion(PrepositionalRektionCase? rektion) {
    List<NominalStyleFvgModel> list = _engine.catalog;
    if (rektion != null) {
      list = _engine.getByRektionCase(rektion);
    }
    if (_currentState.selectedAktionsart != null) {
      list = list.where((f) => f.aktionsartType == _currentState.selectedAktionsart).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((f) => f.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave64UiState(
      activeExemplars: list,
      selectedAktionsart: _currentState.selectedAktionsart,
      selectedRektion: rektion,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<NominalStyleFvgModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedAktionsart != null) {
      list = list.where((f) => f.aktionsartType == _currentState.selectedAktionsart).toList();
    }
    if (_currentState.selectedRektion != null) {
      list = list.where((f) => f.rektionCase == _currentState.selectedRektion).toList();
    }
    _currentState = Vol116Wave64UiState(
      activeExemplars: list,
      selectedAktionsart: _currentState.selectedAktionsart,
      selectedRektion: _currentState.selectedRektion,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave64UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
