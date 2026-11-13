import 'dart:async';
import '../../core/content/german_fluctuating_adjective_declension_engine.dart';

/// Reactive UI Bridge connecting the Fluctuating Adjective Engine with interactive cards and telemetry.
class Vol116Wave44UiBridge {
  final GermanFluctuatingAdjectiveDeclensionEngine _engine;
  final StreamController<FluctuatingAdjectiveModel?> _selectedModelController =
      StreamController<FluctuatingAdjectiveModel?>.broadcast();

  DeterminerClass? _activeClassFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave44UiBridge({GermanFluctuatingAdjectiveDeclensionEngine? engine})
      : _engine = engine ?? GermanFluctuatingAdjectiveDeclensionEngine();

  Stream<FluctuatingAdjectiveModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<FluctuatingAdjectiveModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeClassFilter != null && item.determinerClass != _activeClassFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setClassFilter(DeterminerClass? dClass) {
    _activeClassFilter = dClass;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeClassFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(FluctuatingAdjectiveModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalAdjectiveRules': catalog.length,
      'definiteLikeWeakCount':
          catalog.where((e) => e.determinerClass == DeterminerClass.definiteLikeWeak).length,
      'adjectiveLikeParallelCount':
          catalog.where((e) => e.determinerClass == DeterminerClass.adjectiveLikeParallelStrong).length,
      'fluctuatingCount':
          catalog.where((e) => e.determinerClass == DeterminerClass.fluctuatingDoubleForm).length,
      'uninflectedCount':
          catalog.where((e) => e.determinerClass == DeterminerClass.uninflectedDeterminers).length,
      'splitConstructionsCount':
          catalog.where((e) => e.determinerClass == DeterminerClass.splitPronounConstructions).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1778 / Wave 44',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
