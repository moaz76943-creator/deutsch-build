import 'dart:async';
import '../../core/content/german_comparative_proportional_syntax_engine.dart';

/// State snapshot for UI Bridge Wave 66 (Task 4966).
class Vol116Wave66UiState {
  final List<ComparativeProportionalModel> activeExemplars;
  final ComparativeConstructionType? selectedType;
  final ProportionalScalingDirection? selectedScaling;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave66UiState({
    required this.activeExemplars,
    this.selectedType,
    this.selectedScaling,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave66UiState.initial(GermanComparativeProportionalSyntaxEngine engine) {
    return Vol116Wave66UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Comparative & Proportional Syntax (Task 4966).
class Vol116Wave66UiBridge {
  final GermanComparativeProportionalSyntaxEngine _engine;
  final _stateController = StreamController<Vol116Wave66UiState>.broadcast();

  Vol116Wave66UiState _currentState;

  Vol116Wave66UiBridge({GermanComparativeProportionalSyntaxEngine? engine})
      : _engine = engine ?? GermanComparativeProportionalSyntaxEngine(),
        _currentState = Vol116Wave66UiState.initial(
            engine ?? GermanComparativeProportionalSyntaxEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave66UiState> get stateStream => _stateController.stream;
  Vol116Wave66UiState get state => _currentState;

  void filterByType(ComparativeConstructionType? type) {
    List<ComparativeProportionalModel> list = _engine.catalog;
    if (type != null) {
      list = _engine.getByType(type);
    }
    if (_currentState.selectedScaling != null) {
      list = list.where((c) => c.scalingDirection == _currentState.selectedScaling).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((c) => c.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave66UiState(
      activeExemplars: list,
      selectedType: type,
      selectedScaling: _currentState.selectedScaling,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByScaling(ProportionalScalingDirection? scaling) {
    List<ComparativeProportionalModel> list = _engine.catalog;
    if (scaling != null) {
      list = _engine.getByScaling(scaling);
    }
    if (_currentState.selectedType != null) {
      list = list.where((c) => c.constructionType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((c) => c.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave66UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedScaling: scaling,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<ComparativeProportionalModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedType != null) {
      list = list.where((c) => c.constructionType == _currentState.selectedType).toList();
    }
    if (_currentState.selectedScaling != null) {
      list = list.where((c) => c.scalingDirection == _currentState.selectedScaling).toList();
    }
    _currentState = Vol116Wave66UiState(
      activeExemplars: list,
      selectedType: _currentState.selectedType,
      selectedScaling: _currentState.selectedScaling,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave66UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
