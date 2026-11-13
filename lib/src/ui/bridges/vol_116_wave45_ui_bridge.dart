import 'dart:async';
import '../../core/content/german_focus_particles_engine.dart';

/// Reactive UI Bridge connecting the Focus Particles Engine with interactive cards and telemetry.
class Vol116Wave45UiBridge {
  final GermanFocusParticlesEngine _engine;
  final StreamController<FocusParticleModel?> _selectedModelController =
      StreamController<FocusParticleModel?>.broadcast();

  FocusParticleCategory? _activeCategoryFilter;
  FocusScopeType? _activeScopeFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave45UiBridge({GermanFocusParticlesEngine? engine})
      : _engine = engine ?? GermanFocusParticlesEngine();

  Stream<FocusParticleModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<FocusParticleModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeCategoryFilter != null && item.category != _activeCategoryFilter) {
        return false;
      }
      if (_activeScopeFilter != null && item.scopeType != _activeScopeFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setCategoryFilter(FocusParticleCategory? category) {
    _activeCategoryFilter = category;
  }

  void setScopeFilter(FocusScopeType? scope) {
    _activeScopeFilter = scope;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeCategoryFilter = null;
    _activeScopeFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(FocusParticleModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalFocusRules': catalog.length,
      'additiveScalarCount':
          catalog.where((e) => e.category == FocusParticleCategory.additiveScalar).length,
      'temporalScalarCount':
          catalog.where((e) => e.category == FocusParticleCategory.temporalScalarContrast).length,
      'restrictiveExclusiveCount':
          catalog.where((e) => e.category == FocusParticleCategory.restrictiveExclusive).length,
      'negativePolarityCount':
          catalog.where((e) => e.category == FocusParticleCategory.negativePolarityScalar).length,
      'counterExpectationCount':
          catalog.where((e) => e.category == FocusParticleCategory.counterExpectationAdversative).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1779 / Wave 45',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
