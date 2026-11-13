import 'dart:async';
import '../../core/content/german_prepositional_semantics_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 79 (دلالات حروف الجر وإعرابها)
class Wave79PrepositionUiState {
  final PrepositionEngineeringDomain selectedDomain;
  final PrepositionalSemanticsExemplar activeExemplar;
  final PrepositionValidationResult? lastValidation;
  final PrepositionalSemanticsTelemetry telemetry;

  const Wave79PrepositionUiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة حروف الجر إلى الواجهة
class Vol116Wave79UiBridge {
  final PrepositionalSemanticsEngine _engine;
  final StreamController<Wave79PrepositionUiState> _controller =
      StreamController<Wave79PrepositionUiState>.broadcast();

  PrepositionEngineeringDomain _currentDomain =
      PrepositionEngineeringDomain.renewableEnergyGrid;
  late PrepositionalSemanticsExemplar _currentExemplar;
  PrepositionValidationResult? _lastValidation;

  Vol116Wave79UiBridge({PrepositionalSemanticsEngine? engine})
      : _engine = engine ?? PrepositionalSemanticsEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Wave79PrepositionUiState> get stateStream => _controller.stream;

  Wave79PrepositionUiState get currentState => Wave79PrepositionUiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );

  void selectDomain(PrepositionEngineeringDomain domain, {int seed = 4979}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  PrepositionValidationResult submitAttempt(String userSentence) {
    final result = _engine.validatePrepositionalPhrase(userSentence);
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
