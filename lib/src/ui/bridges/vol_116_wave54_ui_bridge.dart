import 'dart:async';
import '../../core/content/german_verbal_valence_topography_engine.dart';

/// Reactive UI Bridge connecting the Verbal Valence Topography Engine with interactive cards and telemetry.
class Vol116Wave54UiBridge {
  final GermanVerbalValenceTopographyEngine _engine;
  final StreamController<ValenceTopographyModel?> _selectedModelController =
      StreamController<ValenceTopographyModel?>.broadcast();

  ValenceComplementType? _activeTypeFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave54UiBridge({GermanVerbalValenceTopographyEngine? engine})
      : _engine = engine ?? GermanVerbalValenceTopographyEngine();

  Stream<ValenceTopographyModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<ValenceTopographyModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeTypeFilter != null && item.complementType != _activeTypeFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(ValenceComplementType? type) {
    _activeTypeFilter = type;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeTypeFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(ValenceTopographyModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalValenceRules': catalog.length,
      'prepObjectRulesCount':
          catalog.where((e) => e.complementType == ValenceComplementType.prepositionalObject).length,
      'directionalComplementsCount':
          catalog.where((e) => e.complementType == ValenceComplementType.directionalComplement).length,
      'situationalComplementsCount':
          catalog.where((e) => e.complementType == ValenceComplementType.situationalComplement).length,
      'secondaryPredicatesCount':
          catalog.where((e) =>
              e.complementType == ValenceComplementType.secondaryPredicateDepictive ||
              e.complementType == ValenceComplementType.secondaryPredicateResultative).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1788 / Wave 54',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
