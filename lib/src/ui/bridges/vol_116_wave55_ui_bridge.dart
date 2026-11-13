import 'dart:async';
import '../../core/content/german_modal_particles_intersubjectivity_engine.dart';

/// UI State for the German Modal Particles & Intersubjectivity Masterclass.
class Vol116Wave55UiState {
  final List<ModalParticleModel> activeExemplars;
  final ModalParticleType? selectedFilter;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave55UiState({
    required this.activeExemplars,
    this.selectedFilter,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave55UiState.initial(
      GermanModalParticlesIntersubjectivityEngine engine) {
    return Vol116Wave55UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Volume 116 Wave 55 (Task 4955).
class Vol116Wave55UiBridge {
  final GermanModalParticlesIntersubjectivityEngine _engine;
  final _stateController = StreamController<Vol116Wave55UiState>.broadcast();

  Vol116Wave55UiState _currentState;

  Vol116Wave55UiBridge({GermanModalParticlesIntersubjectivityEngine? engine})
      : _engine = engine ?? GermanModalParticlesIntersubjectivityEngine(),
        _currentState = Vol116Wave55UiState.initial(
            engine ?? GermanModalParticlesIntersubjectivityEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave55UiState> get stateStream => _stateController.stream;
  Vol116Wave55UiState get state => _currentState;

  void filterByParticle(ModalParticleType? particle) {
    List<ModalParticleModel> list = _engine.catalog;
    if (particle != null) {
      list = _engine.getByParticle(particle);
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((e) => e.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave55UiState(
      activeExemplars: list,
      selectedFilter: particle,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<ModalParticleModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedFilter != null) {
      list = list.where((e) => e.particle == _currentState.selectedFilter).toList();
    }
    _currentState = Vol116Wave55UiState(
      activeExemplars: list,
      selectedFilter: _currentState.selectedFilter,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave55UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
