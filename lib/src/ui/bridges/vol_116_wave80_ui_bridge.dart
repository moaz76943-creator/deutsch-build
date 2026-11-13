import 'dart:async';
import '../../core/content/german_n_declension_gender_homonym_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 80 (الإعراب الضعيف والمتجانسات)
class Wave80MorphologyUiState {
  final MorphologyEngineeringDomain selectedDomain;
  final DeclensionHomonymExemplar activeExemplar;
  final MorphologyValidationResult? lastValidation;
  final NDeclensionHomonymTelemetry telemetry;

  const Wave80MorphologyUiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة الإعراب الضعيف إلى الواجهة
class Vol116Wave80UiBridge {
  final NDeclensionGenderHomonymEngine _engine;
  final StreamController<Wave80MorphologyUiState> _controller =
      StreamController<Wave80MorphologyUiState>.broadcast();

  MorphologyEngineeringDomain _currentDomain =
      MorphologyEngineeringDomain.renewableEnergyGrid;
  late DeclensionHomonymExemplar _currentExemplar;
  MorphologyValidationResult? _lastValidation;

  Vol116Wave80UiBridge({NDeclensionGenderHomonymEngine? engine})
      : _engine = engine ?? NDeclensionGenderHomonymEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Wave80MorphologyUiState> get stateStream => _controller.stream;

  Wave80MorphologyUiState get currentState => Wave80MorphologyUiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );

  void selectDomain(MorphologyEngineeringDomain domain, {int seed = 4980}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  MorphologyValidationResult submitAttempt(String userSentence) {
    final result = _engine.validateMorphology(userSentence);
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
