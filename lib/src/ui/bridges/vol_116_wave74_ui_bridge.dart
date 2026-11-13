import 'dart:async';
import '../../core/content/german_topological_verb_cluster_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 74 (الطوبولوجيا والعناقيد الفعلية)
class Wave74TopologicalUiState {
  final TopologicalEngineeringDomain selectedDomain;
  final TopologicalClusterExemplar activeExemplar;
  final TopologicalValidationResult? lastValidation;
  final TopologicalClusterTelemetry telemetry;

  const Wave74TopologicalUiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة العناقيد الفعلية إلى الواجهة
class Vol116Wave74UiBridge {
  final TopologicalVerbClusterEngine _engine;
  final StreamController<Wave74TopologicalUiState> _controller =
      StreamController<Wave74TopologicalUiState>.broadcast();

  TopologicalEngineeringDomain _currentDomain =
      TopologicalEngineeringDomain.renewableEnergyGrid;
  late TopologicalClusterExemplar _currentExemplar;
  TopologicalValidationResult? _lastValidation;

  Vol116Wave74UiBridge({TopologicalVerbClusterEngine? engine})
      : _engine = engine ?? TopologicalVerbClusterEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Wave74TopologicalUiState> get stateStream => _controller.stream;

  Wave74TopologicalUiState get currentState => Wave74TopologicalUiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );

  void selectDomain(TopologicalEngineeringDomain domain, {int seed = 4974}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  TopologicalValidationResult submitAttempt(String userSentence) {
    final result = _engine.validateClusterSyntax(userSentence);
    _lastValidation = result;
    _emit();
    return result;
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(currentState);
    }
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
