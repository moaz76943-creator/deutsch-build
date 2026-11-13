import 'dart:async';
import '../../core/content/german_comma_semantics_orthography_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 78 (الترقيم الدلالي والفصل والوصل)
class Wave78OrthographyUiState {
  final OrthographyEngineeringDomain selectedDomain;
  final CommaOrthographyExemplar activeExemplar;
  final OrthographyValidationResult? lastValidation;
  final CommaOrthographyTelemetry telemetry;

  const Wave78OrthographyUiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة الترقيم الدلالي إلى الواجهة
class Vol116Wave78UiBridge {
  final CommaSemanticsOrthographyEngine _engine;
  final StreamController<Wave78OrthographyUiState> _controller =
      StreamController<Wave78OrthographyUiState>.broadcast();

  OrthographyEngineeringDomain _currentDomain =
      OrthographyEngineeringDomain.renewableEnergyGrid;
  late CommaOrthographyExemplar _currentExemplar;
  OrthographyValidationResult? _lastValidation;

  Vol116Wave78UiBridge({CommaSemanticsOrthographyEngine? engine})
      : _engine = engine ?? CommaSemanticsOrthographyEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Wave78OrthographyUiState> get stateStream => _controller.stream;

  Wave78OrthographyUiState get currentState => Wave78OrthographyUiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );

  void selectDomain(OrthographyEngineeringDomain domain, {int seed = 4978}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  OrthographyValidationResult submitAttempt(String userSentence) {
    final result = _engine.validateOrthographyAndComma(userSentence);
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
