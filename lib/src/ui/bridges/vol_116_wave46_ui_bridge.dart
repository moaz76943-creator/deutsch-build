import 'dart:async';
import '../../core/content/german_verb_polysemy_rection_engine.dart';

/// Reactive UI Bridge connecting the Verb Polysemy Rection Engine with interactive visual cards and telemetry.
class Vol116Wave46UiBridge {
  final GermanVerbPolysemyRectionEngine _engine;
  final StreamController<VerbRectionVariantModel?> _selectedVariantController =
      StreamController<VerbRectionVariantModel?>.broadcast();

  BaseVerbGroup? _activeVerbFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave46UiBridge({GermanVerbPolysemyRectionEngine? engine})
      : _engine = engine ?? GermanVerbPolysemyRectionEngine();

  Stream<VerbRectionVariantModel?> get selectedVariantStream =>
      _selectedVariantController.stream;

  List<VerbRectionVariantModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeVerbFilter != null && item.baseVerb != _activeVerbFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setVerbFilter(BaseVerbGroup? verb) {
    _activeVerbFilter = verb;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeVerbFilter = null;
    _activeDomainFilter = null;
  }

  void selectVariant(VerbRectionVariantModel variant) {
    _selectedVariantController.add(variant);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalRectionRules': catalog.length,
      'bestehenVariantsCount':
          catalog.where((e) => e.baseVerb == BaseVerbGroup.bestehen).length,
      'ankommenVariantsCount':
          catalog.where((e) => e.baseVerb == BaseVerbGroup.ankommen).length,
      'haltenVariantsCount':
          catalog.where((e) => e.baseVerb == BaseVerbGroup.halten).length,
      'passenVariantsCount':
          catalog.where((e) => e.baseVerb == BaseVerbGroup.passen).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1780 / Wave 46',
    };
  }

  void dispose() {
    _selectedVariantController.close();
  }
}
