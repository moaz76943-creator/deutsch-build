import 'dart:async';
import '../../core/content/german_sentential_relatives_engine.dart';

/// Reactive UI Bridge for Volume 116 Wave 38 (Sentential Relatives Engine).
class Vol116Wave38UiBridge {
  final GermanSententialRelativesEngine _engine;
  final StreamController<SententialRelativeModel?> _selectedModelController =
      StreamController<SententialRelativeModel?>.broadcast();

  SententialRelativeType? _selectedTypeFilter;
  LinguisticRegister? _selectedRegisterFilter;

  Vol116Wave38UiBridge({GermanSententialRelativesEngine? engine})
      : _engine = engine ?? GermanSententialRelativesEngine();

  Stream<SententialRelativeModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<SententialRelativeModel> get currentItems {
    return _engine.catalog.where((item) {
      if (_selectedTypeFilter != null && item.type != _selectedTypeFilter) {
        return false;
      }
      if (_selectedRegisterFilter != null && item.register != _selectedRegisterFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(SententialRelativeType? type) {
    _selectedTypeFilter = type;
  }

  void setRegisterFilter(LinguisticRegister? register) {
    _selectedRegisterFilter = register;
  }

  void clearFilters() {
    _selectedTypeFilter = null;
    _selectedRegisterFilter = null;
  }

  void selectModel(SententialRelativeModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getDiagnosticTelemetry() {
    final items = _engine.catalog;
    return {
      'totalSententialRules': items.length,
      'propositionalWasCount':
          items.where((e) => e.type == SententialRelativeType.propositionalWas).length,
      'pronominalAdverbCount':
          items.where((e) => e.type == SententialRelativeType.pronominalAdverbRelative).length,
      'causalConsecutiveCount':
          items.where((e) => e.type == SententialRelativeType.causalConsecutiveRelative).length,
      'indefiniteNeuterCount':
          items.where((e) => e.type == SententialRelativeType.indefiniteNeuterAntecedent).length,
      'cefrLevel': 'C1-C2 Masterclass',
      'privacyPolicy': 'Strict Zero PII, Offline Sovereign Engine',
      'version': 'v116.38.0-sovereign',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
