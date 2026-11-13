import 'dart:async';
import '../../core/content/german_adjective_nominalization_declension_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 75 (تصريف الصفات والأسماء المشتقة)
class Wave75DeclensionUiState {
  final DeclensionEngineeringDomain selectedDomain;
  final AdjectiveDeclensionExemplar activeExemplar;
  final DeclensionValidationResult? lastValidation;
  final AdjectiveDeclensionTelemetry telemetry;

  const Wave75DeclensionUiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة تصريف الصفات إلى الواجهة
class Vol116Wave75UiBridge {
  final AdjectiveNominalizationDeclensionEngine _engine;
  final StreamController<Wave75DeclensionUiState> _controller =
      StreamController<Wave75DeclensionUiState>.broadcast();

  DeclensionEngineeringDomain _currentDomain =
      DeclensionEngineeringDomain.renewableEnergyGrid;
  late AdjectiveDeclensionExemplar _currentExemplar;
  DeclensionValidationResult? _lastValidation;

  Vol116Wave75UiBridge({AdjectiveNominalizationDeclensionEngine? engine})
      : _engine = engine ?? AdjectiveNominalizationDeclensionEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Wave75DeclensionUiState> get stateStream => _controller.stream;

  Wave75DeclensionUiState get currentState => Wave75DeclensionUiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );

  void selectDomain(DeclensionEngineeringDomain domain, {int seed = 4975}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  DeclensionValidationResult submitAttempt(String userSentence) {
    final result = _engine.validateDeclension(userSentence);
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
