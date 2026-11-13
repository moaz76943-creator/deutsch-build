import 'dart:async';
import '../../core/content/german_variable_prefix_verbs_engine.dart';

/// State snapshot for UI Bridge Wave 58 (Task 4958).
class Vol116Wave58UiState {
  final List<VariablePrefixVerbModel> activeExemplars;
  final PrefixMorpheme? selectedPrefix;
  final SeparabilityStatus? selectedSeparability;
  final CommunicativeDomain? selectedDomain;
  final Map<String, dynamic> telemetry;
  final bool isReady;

  const Vol116Wave58UiState({
    required this.activeExemplars,
    this.selectedPrefix,
    this.selectedSeparability,
    this.selectedDomain,
    required this.telemetry,
    required this.isReady,
  });

  factory Vol116Wave58UiState.initial(
      GermanVariablePrefixVerbsEngine engine) {
    return Vol116Wave58UiState(
      activeExemplars: engine.catalog,
      telemetry: engine.generateTelemetrySnapshot(),
      isReady: true,
    );
  }
}

/// Reactive UI Bridge for Variable Prefix Verbs (Task 4958).
class Vol116Wave58UiBridge {
  final GermanVariablePrefixVerbsEngine _engine;
  final _stateController = StreamController<Vol116Wave58UiState>.broadcast();

  Vol116Wave58UiState _currentState;

  Vol116Wave58UiBridge({GermanVariablePrefixVerbsEngine? engine})
      : _engine = engine ?? GermanVariablePrefixVerbsEngine(),
        _currentState = Vol116Wave58UiState.initial(
            engine ?? GermanVariablePrefixVerbsEngine()) {
    _stateController.add(_currentState);
  }

  Stream<Vol116Wave58UiState> get stateStream => _stateController.stream;
  Vol116Wave58UiState get state => _currentState;

  void filterByPrefix(PrefixMorpheme? prefix) {
    List<VariablePrefixVerbModel> list = _engine.catalog;
    if (prefix != null) {
      list = _engine.getByPrefix(prefix);
    }
    if (_currentState.selectedSeparability != null) {
      list = list.where((v) => v.separabilityStatus == _currentState.selectedSeparability).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((v) => v.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave58UiState(
      activeExemplars: list,
      selectedPrefix: prefix,
      selectedSeparability: _currentState.selectedSeparability,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterBySeparability(SeparabilityStatus? status) {
    List<VariablePrefixVerbModel> list = _engine.catalog;
    if (status != null) {
      list = _engine.getBySeparability(status);
    }
    if (_currentState.selectedPrefix != null) {
      list = list.where((v) => v.prefix == _currentState.selectedPrefix).toList();
    }
    if (_currentState.selectedDomain != null) {
      list = list.where((v) => v.domain == _currentState.selectedDomain).toList();
    }
    _currentState = Vol116Wave58UiState(
      activeExemplars: list,
      selectedPrefix: _currentState.selectedPrefix,
      selectedSeparability: status,
      selectedDomain: _currentState.selectedDomain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void filterByDomain(CommunicativeDomain? domain) {
    List<VariablePrefixVerbModel> list = _engine.catalog;
    if (domain != null) {
      list = _engine.getByDomain(domain);
    }
    if (_currentState.selectedPrefix != null) {
      list = list.where((v) => v.prefix == _currentState.selectedPrefix).toList();
    }
    if (_currentState.selectedSeparability != null) {
      list = list.where((v) => v.separabilityStatus == _currentState.selectedSeparability).toList();
    }
    _currentState = Vol116Wave58UiState(
      activeExemplars: list,
      selectedPrefix: _currentState.selectedPrefix,
      selectedSeparability: _currentState.selectedSeparability,
      selectedDomain: domain,
      telemetry: _engine.generateTelemetrySnapshot(),
      isReady: true,
    );
    _stateController.add(_currentState);
  }

  void resetFilters() {
    _currentState = Vol116Wave58UiState.initial(_engine);
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
