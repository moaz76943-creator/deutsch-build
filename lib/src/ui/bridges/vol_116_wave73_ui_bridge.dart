import 'dart:async';
import '../../core/content/german_complex_relative_clauses_engine.dart';

/// حالة الواجهة التفاعلية لجسر الوحدة 116 - الموجة 73 (الجمل الموصولة المعقدة)
class Wave73RelativeUiState {
  final EngineeringRelativeDomain selectedDomain;
  final ComplexRelativeExemplar activeExemplar;
  final RelativeValidationResult? lastValidation;
  final ComplexRelativeTelemetry telemetry;

  const Wave73RelativeUiState({
    required this.selectedDomain,
    required this.activeExemplar,
    required this.lastValidation,
    required this.telemetry,
  });
}

/// جسر ربط تفاعلي متوافق مع شاشات AMOLED (144Hz) لنقل حالة الجمل الموصولة إلى الواجهة
class Vol116Wave73UiBridge {
  final ComplexRelativeClauseEngine _engine;
  final StreamController<Wave73RelativeUiState> _controller =
      StreamController<Wave73RelativeUiState>.broadcast();

  EngineeringRelativeDomain _currentDomain = EngineeringRelativeDomain.renewableEnergyGrid;
  late ComplexRelativeExemplar _currentExemplar;
  RelativeValidationResult? _lastValidation;

  Vol116Wave73UiBridge({ComplexRelativeClauseEngine? engine})
      : _engine = engine ?? ComplexRelativeClauseEngine() {
    _currentExemplar = _engine.pickExemplarForDrill(domain: _currentDomain);
  }

  Stream<Wave73RelativeUiState> get stateStream => _controller.stream;

  Wave73RelativeUiState get currentState => Wave73RelativeUiState(
        selectedDomain: _currentDomain,
        activeExemplar: _currentExemplar,
        lastValidation: _lastValidation,
        telemetry: _engine.telemetry,
      );

  void selectDomain(EngineeringRelativeDomain domain, {int seed = 4973}) {
    _currentDomain = domain;
    _currentExemplar = _engine.pickExemplarForDrill(domain: domain, seed: seed);
    _lastValidation = null;
    _emit();
  }

  RelativeValidationResult submitAttempt(
    String userSentence, {
    bool antecedentIsConcreteNoun = true,
    bool antecedentIsIndefiniteOrClause = false,
  }) {
    final result = _engine.validateRelativeSentence(
      userSentence,
      antecedentIsConcreteNoun: antecedentIsConcreteNoun,
      antecedentIsIndefiniteOrClause: antecedentIsIndefiniteOrClause,
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
