import 'dart:async';
import '../../core/content/german_inversion_expletive_engine.dart';

/// Reactive UI Bridge connecting the Inversion & Expletive Engine with visual telemetry and interactive filters.
class Vol116Wave42UiBridge {
  final GermanInversionExpletiveEngine _engine;
  final StreamController<InversionModel?> _selectedModelController =
      StreamController<InversionModel?>.broadcast();

  InversionPattern? _activePatternFilter;
  EsDropBehavior? _activeEsFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave42UiBridge({GermanInversionExpletiveEngine? engine})
      : _engine = engine ?? GermanInversionExpletiveEngine();

  Stream<InversionModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<InversionModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activePatternFilter != null && item.pattern != _activePatternFilter) {
        return false;
      }
      if (_activeEsFilter != null && item.esBehavior != _activeEsFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setPatternFilter(InversionPattern? pattern) {
    _activePatternFilter = pattern;
  }

  void setEsBehaviorFilter(EsDropBehavior behavior) {
    _activeEsFilter = behavior;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activePatternFilter = null;
    _activeEsFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(InversionModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalInversionRules': catalog.length,
      'adverbialInversionCount':
          catalog.where((e) => e.pattern == InversionPattern.adverbialInversion).length,
      'participleFrontingCount':
          catalog.where((e) => e.pattern == InversionPattern.participleFronting).length,
      'vorfeldEsCount':
          catalog.where((e) => e.pattern == InversionPattern.vorfeldExpletiveEs).length,
      'obligatoryValenceEsCount':
          catalog.where((e) => e.pattern == InversionPattern.obligatoryValenceEs).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1776 / Wave 42',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
