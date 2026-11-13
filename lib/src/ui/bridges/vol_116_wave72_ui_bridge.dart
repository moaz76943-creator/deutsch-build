import 'dart:async';
import '../../core/content/german_infinitival_adjuncts_control_engine.dart';

/// State snapshot for UI Bridge Wave 72 (Task 4972).
class Vol116Wave72UiState {
  final List<InfinitivalAdjunctModel> activeExemplars;
  final InfinitivalAdjunctType? selectedType;
  final SubjectControlStatus? selectedControl;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave72UiState({
    required this.activeExemplars,
    this.selectedType,
    this.selectedControl,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave72UiState.initial(GermanInfinitivalAdjunctsControlEngine engine) {
    return Vol116Wave72UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Infinitival Adjuncts & Subject Control (Task 4972).
class Vol116Wave72UiBridge {
  final GermanInfinitivalAdjunctsControlEngine _engine;
  final _stateController = StreamController<Vol116Wave72UiState>.broadcast();

  Vol116Wave72UiState _currentState;

  Vol116Wave72UiBridge({GermanInfinitivalAdjunctsControlEngine? engine})
      : _engine = engine ?? GermanInfinitivalAdjunctsControlEngine(),
        _currentState = Vol116Wave72UiState.initial(
            engine ?? GermanInfinitivalAdjunctsControlEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave72UiState> get stateStream => _stateController.stream;
  Vol116Wave72UiState get state => _currentState;

  void filterByType(InfinitivalAdjunctType? type) {
    List<InfinitivalAdjunctModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByType(type);
    }
    if (_currentState.selectedControl != null) {
      list = list.where((i) => i.controlStatus == _currentState.selectedControl).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((i) => i.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave72UiState(
      activeExemplars: list,
      selectedType: type,
      selectedControl: _currentState.selectedControl,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByControl(SubjectControlStatus? control) {
    List<InfinitivalAdjunctModel> list = _engine.catalog;
    if (control != null) {
      list = _engine.getByControlStatus(control);
    }
    if (_currentState.selectedType != null) {
      list = list.where((i) => i.adjunctType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((i) => i.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave72UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedControl: control,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<InfinitivalAdjunctModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedType != null) {
      list = list.where((i) => i.adjunctType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedControl != null) {
      list = list.where((i) => i.controlStatus == _currentState.selectedControl).toList();
    }
    _currentState = Vol116Wave72UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedControl: _currentState.selectedControl,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave72UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
