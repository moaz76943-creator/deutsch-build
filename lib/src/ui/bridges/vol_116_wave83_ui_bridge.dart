import 'dart:async';
import '../../core/content/german_word_formation_derivation_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 83 (الاشتقاق الصرفي وتكوين الكلمات)
class Vol116Wave83UiState {
  final DerivationEngineeringDomain selectedDomain;
  final WordFormationExemplar activeExemplar;
  final WordFormationValidationResult? lastValidation;
  final WordFormationTelemetry telemetry;

  const Vol116Wave83UiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة الاشتقاق الصرفي إلى الواجهة
class Vol116Wave83UiBridge {
  final GermanWordFormationDerivationEngine _engine;
  final StreamController<Vol116Wave83UiState> _controller =
      StreamController<Vol116Wave83UiState>.broadcast();

  DerivationEngineeringDomain _currentDomain =
      DerivationEngineeringDomain.renewableEnergyGrid;
  late WordFormationExemplar _currentExemplar;
  WordFormationValidationResult? _lastValidation;

  Vol116Wave83UiBridge({GermanWordFormationDerivationEngine? engine})
      : _engine = engine ?? GermanWordFormationDerivationEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Vol116Wave83UiState> get stateStream => _controller.stream;
  Vol116Wave83UiState get currentState => Vol116Wave83UiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );
  Vol116Wave83UiState get state => currentState;

  List<WordFormationExemplar> get activeExemplars =>
      _engine.getByDomain(_currentDomain);

  Map<String, dynamic> get telemetrySnapshot =>
      _engine.generateTelemetrySnapshot();

  void selectDomain(DerivationEngineeringDomain domain, {int seed = 4983}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  void filterByDomain(DerivationEngineeringDomain? domain) {
    selectDomain(domain ?? DerivationEngineeringDomain.renewableEnergyGrid);
  }

  void resetFilters() {
    selectDomain(DerivationEngineeringDomain.renewableEnergyGrid);
  }

  WordFormationValidationResult submitAttempt(String userSentence) {
    final result = _engine.validateWordFormation(userSentence);
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
