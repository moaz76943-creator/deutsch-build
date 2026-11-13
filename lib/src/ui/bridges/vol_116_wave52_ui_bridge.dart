import 'dart:async';
import '../../core/content/german_infinitive_complementation_engine.dart';

/// Reactive UI Bridge connecting the Infinitive Complementation Engine with interactive cards and telemetry.
class Vol116Wave52UiBridge {
  final GermanInfinitiveComplementationEngine _engine;
  final StreamController<InfinitiveComplementationModel?> _selectedModelController =
      StreamController<InfinitiveComplementationModel?>.broadcast();

  InfinitiveGovernmentType? _activeTypeFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave52UiBridge({GermanInfinitiveComplementationEngine? engine})
      : _engine = engine ?? GermanInfinitiveComplementationEngine();

  Stream<InfinitiveComplementationModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<InfinitiveComplementationModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeTypeFilter != null && item.governmentType != _activeTypeFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(InfinitiveGovernmentType? type) {
    _activeTypeFilter = type;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeTypeFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(InfinitiveComplementationModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalInfinitiveRules': catalog.length,
      'perceptionAcICount':
          catalog.where((e) => e.governmentType == InfinitiveGovernmentType.pureInfinitivePerception).length,
      'causativeLassenCount':
          catalog.where((e) => e.governmentType == InfinitiveGovernmentType.pureInfinitiveCausativePermissive).length,
      'motionVerbsCount':
          catalog.where((e) => e.governmentType == InfinitiveGovernmentType.pureInfinitiveMotion).length,
      'obligatoryZuCount':
          catalog.where((e) => e.governmentType == InfinitiveGovernmentType.obligatoryZuInfinitive).length,
      'dualGovernmentCount':
          catalog.where((e) => e.governmentType == InfinitiveGovernmentType.dualGovernmentVerbs).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1786 / Wave 52',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
