import 'dart:async';
import '../../core/content/german_modal_polysemy_epistemic_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 81 (تعدد معاني الأفعال الناقصة)
class Wave81ModalUiState {
  final ModalEngineeringDomain selectedDomain;
  final ModalPolysemyExemplar activeExemplar;
  final ModalPolysemyValidationResult? lastValidation;
  final ModalPolysemyTelemetry telemetry;

  const Wave81ModalUiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة الأفعال الناقصة إلى الواجهة
class Vol116Wave81UiBridge {
  final ModalPolysemyEpistemicEngine _engine;
  final StreamController<Wave81ModalUiState> _controller =
      StreamController<Wave81ModalUiState>.broadcast();

  ModalEngineeringDomain _currentDomain =
      ModalEngineeringDomain.renewableEnergyGrid;
  late ModalPolysemyExemplar _currentExemplar;
  ModalPolysemyValidationResult? _lastValidation;

  Vol116Wave81UiBridge({ModalPolysemyEpistemicEngine? engine})
      : _engine = engine ?? ModalPolysemyEpistemicEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Wave81ModalUiState> get stateStream => _controller.stream;

  Wave81ModalUiState get currentState => Wave81ModalUiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );

  void selectDomain(ModalEngineeringDomain domain, {int seed = 4981}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  ModalPolysemyValidationResult submitAttempt(
    String userSentence, {
    bool expressesStrictProhibition = false,
  }) {
    final result = _engine.validateModalUsage(
      userSentence,
      expressesStrictProhibition: expressesStrictProhibition,
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
