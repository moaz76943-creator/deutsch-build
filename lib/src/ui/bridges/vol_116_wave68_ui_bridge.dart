import 'dart:async';
import '../../core/content/german_negation_scope_polarity_engine.dart';

/// State snapshot for UI Bridge Wave 68 (Task 4968).
class Vol116Wave68UiState {
  final List<NegationScopePolarityModel> activeExemplars;
  final NegationScopeType? selectedScopeType;
  final MittelfeldNegationAnchor? selectedAnchor;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave68UiState({
    required this.activeExemplars,
    this.selectedScopeType,
    this.selectedAnchor,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave68UiState.initial(GermanNegationScopePolarityEngine engine) {
    return Vol116Wave68UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Negation Scope & Polarity Licensing (Task 4968).
class Vol116Wave68UiBridge {
  final GermanNegationScopePolarityEngine _engine;
  final _stateController = StreamController<Vol116Wave68UiState>.broadcast();

  Vol116Wave68UiState _currentState;

  Vol116Wave68UiBridge({GermanNegationScopePolarityEngine? engine})
      : _engine = engine ?? GermanNegationScopePolarityEngine(),
        _currentState = Vol116Wave68UiState.initial(
            engine ?? GermanNegationScopePolarityEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave68UiState> get stateStream => _stateController.stream;
  Vol116Wave68UiState get state => _currentState;

  void filterByScopeType(NegationScopeType? type) {
    List<NegationScopePolarityModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByScopeType(type);
    }
    if (_currentState.selectedAnchor != null) {
      list = list.where((n) => n.anchorPosition == _currentState.selectedAnchor).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((n) => n.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave68UiState(
      activeExemplars: list,
      selectedScopeType: type,
      selectedAnchor: _currentState.selectedAnchor,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByAnchor(MittelfeldNegationAnchor? anchor) {
    List<NegationScopePolarityModel> list = _engine.catalog;
    if (anchor != null) {
      list = _engine.getByAnchor(anchor);
    }
    if (_currentState.selectedScopeType != null) {
      list = list.where((n) => n.scopeType == _currentState.selectedScopeType).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((n) => n.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave68UiState(
      activeExemplars: list,
      selectedScopeType: _currentState.selectedScopeType,
      selectedAnchor: anchor,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<NegationScopePolarityModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedScopeType != null) {
      list = list.where((n) => n.scopeType == _currentState.selectedScopeType).toList();
    }
    if (_currentState.selectedAnchor != null) {
      list = list.where((n) => n.anchorPosition == _currentState.selectedAnchor).toList();
    }
    _currentState = Vol116Wave68UiState(
      activeExemplars: list,
      selectedScopeType: _currentState.selectedScopeType,
      selectedAnchor: _currentState.selectedAnchor,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave68UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
