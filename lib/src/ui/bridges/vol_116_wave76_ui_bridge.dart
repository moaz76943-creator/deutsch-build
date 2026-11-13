import 'dart:async';
import '../../core/content/german_reflexive_reciprocal_pronominal_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 76 (الضمائر الانعكاسية والتبادلية)
class Wave76PronominalUiState {
  final PronominalEngineeringDomain selectedDomain;
  final ReflexivePronominalExemplar activeExemplar;
  final PronominalValidationResult? lastValidation;
  final ReflexivePronominalTelemetry telemetry;

  const Wave76PronominalUiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة الضمائر إلى الواجهة
class Vol116Wave76UiBridge {
  final ReflexiveReciprocalPronominalEngine _engine;
  final StreamController<Wave76PronominalUiState> _controller =
      StreamController<Wave76PronominalUiState>.broadcast();

  PronominalEngineeringDomain _currentDomain =
      PronominalEngineeringDomain.renewableEnergyGrid;
  late ReflexivePronominalExemplar _currentExemplar;
  PronominalValidationResult? _lastValidation;

  Vol116Wave76UiBridge({ReflexiveReciprocalPronominalEngine? engine})
      : _engine = engine ?? ReflexiveReciprocalPronominalEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Wave76PronominalUiState> get stateStream => _controller.stream;

  Wave76PronominalUiState get currentState => Wave76PronominalUiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );

  void selectDomain(PronominalEngineeringDomain domain, {int seed = 4976}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  PronominalValidationResult submitAttempt(
    String userSentence, {
    bool refersToPersonOrTeam = false,
  }) {
    final result = _engine.validatePronominalUsage(
      userSentence,
      refersToPersonOrTeam: refersToPersonOrTeam,
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
