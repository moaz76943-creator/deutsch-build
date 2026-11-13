import 'dart:async';
import '../../core/content/german_concessive_adversative_connectors_engine.dart';

/// State snapshot for UI Bridge Wave 65 (Task 4965).
class Vol116Wave65UiState {
  final List<ConcessiveAdversativeConnectorModel> activeExemplars;
  final ConnectorTopologyType? selectedTopology;
  final ClausePositionSyntax? selectedSyntax;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave65UiState({
    required this.activeExemplars,
    this.selectedTopology,
    this.selectedSyntax,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave65UiState.initial(GermanConcessiveAdversativeConnectorsEngine engine) {
    return Vol116Wave65UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Complex Connectors & Topology (Task 4965).
class Vol116Wave65UiBridge {
  final GermanConcessiveAdversativeConnectorsEngine _engine;
  final _stateController = StreamController<Vol116Wave65UiState>.broadcast();

  Vol116Wave65UiState _currentState;

  Vol116Wave65UiBridge({GermanConcessiveAdversativeConnectorsEngine? engine})
      : _engine = engine ?? GermanConcessiveAdversativeConnectorsEngine(),
        _currentState = Vol116Wave65UiState.initial(
            engine ?? GermanConcessiveAdversativeConnectorsEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave65UiState> get stateStream => _stateController.stream;
  Vol116Wave65UiState get state => _currentState;

  void filterByTopology(ConnectorTopologyType? type) {
    List<ConcessiveAdversativeConnectorModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByTopology(type);
    }
    if (_currentState.selectedSyntax != null) {
      list = list.where((c) => c.positionSyntax == _currentState.selectedSyntax).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((c) => c.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave65UiState(
      activeExemplars: list,
      selectedTopology: type,
      selectedSyntax: _currentState.selectedSyntax,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterBySyntax(ClausePositionSyntax? syntax) {
    List<ConcessiveAdversativeConnectorModel> list = _engine.catalog;
    if (syntax != null) {
      list = _engine.getBySyntax(syntax);
    }
    if (_currentState.selectedTopology != null) {
      list = list.where((c) => c.topologyType == _currentState.selectedTopology).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((c) => c.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave65UiState(
      activeExemplars: list,
      selectedTopology: _currentState.selectedTopology,
      selectedSyntax: syntax,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<ConcessiveAdversativeConnectorModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedTopology != null) {
      list = list.where((c) => c.topologyType == _currentState.selectedTopology).toList();
    }
    if (_currentState.selectedSyntax != null) {
      list = list.where((c) => c.positionSyntax == _currentState.selectedSyntax).toList();
    }
    _currentState = Vol116Wave65UiState(
      activeExemplars: list,
      selectedTopology: _currentState.selectedTopology,
      selectedSyntax: _currentState.selectedSyntax,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave65UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
