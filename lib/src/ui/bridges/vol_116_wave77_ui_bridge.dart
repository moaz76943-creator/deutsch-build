import 'dart:async';
import '../../core/content/german_subject_verb_agreement_kongruenz_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 77 (مطابقة الفاعل والفعل Kongruenz)
class Wave77KongruenzUiState {
  final KongruenzEngineeringDomain selectedDomain;
  final KongruenzExemplar activeExemplar;
  final KongruenzValidationResult? lastValidation;
  final KongruenzTelemetry telemetry;

  const Wave77KongruenzUiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة المطابقة إلى الواجهة
class Vol116Wave77UiBridge {
  final SubjectVerbAgreementKongruenzEngine _engine;
  final StreamController<Wave77KongruenzUiState> _controller =
      StreamController<Wave77KongruenzUiState>.broadcast();

  KongruenzEngineeringDomain _currentDomain =
      KongruenzEngineeringDomain.renewableEnergyGrid;
  late KongruenzExemplar _currentExemplar;
  KongruenzValidationResult? _lastValidation;

  Vol116Wave77UiBridge({SubjectVerbAgreementKongruenzEngine? engine})
      : _engine = engine ?? SubjectVerbAgreementKongruenzEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Wave77KongruenzUiState> get stateStream => _controller.stream;

  Wave77KongruenzUiState get currentState => Wave77KongruenzUiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );

  void selectDomain(KongruenzEngineeringDomain domain, {int seed = 4977}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  KongruenzValidationResult submitAttempt(
    String userSentence, {
    bool predicateOrRealSubjectIsPlural = true,
  }) {
    final result = _engine.validateKongruenz(
      userSentence,
      predicateOrRealSubjectIsPlural: predicateOrRealSubjectIsPlural,
    );
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
