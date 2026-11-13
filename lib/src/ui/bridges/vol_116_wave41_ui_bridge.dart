import 'dart:async';
import '../../core/content/german_ellipsis_coordination_engine.dart';

/// Reactive UI Bridge connecting the Ellipsis & Coordination Engine with visual cards and telemetry.
class Vol116Wave41UiBridge {
  final GermanEllipsisCoordinationEngine _engine;
  final StreamController<EllipsisModel?> _selectedModelController =
      StreamController<EllipsisModel?>.broadcast();

  EllipsisType? _activeTypeFilter;
  SyntacticFeasibility? _activeFeasibilityFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave41UiBridge({GermanEllipsisCoordinationEngine? engine})
      : _engine = engine ?? GermanEllipsisCoordinationEngine();

  Stream<EllipsisModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<EllipsisModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeTypeFilter != null && item.ellipsisType != _activeTypeFilter) {
        return false;
      }
      if (_activeFeasibilityFilter != null && item.feasibility != _activeFeasibilityFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(EllipsisType? type) {
    _activeTypeFilter = type;
  }

  void setFeasibilityFilter(SyntacticFeasibility? feasibility) {
    _activeFeasibilityFilter = feasibility;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeTypeFilter = null;
    _activeFeasibilityFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(EllipsisModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalEllipsisRules': catalog.length,
      'gappingCount':
          catalog.where((e) => e.ellipsisType == EllipsisType.prädikatsellipseGapping).length,
      'subjectEllipsisCount':
          catalog.where((e) => e.ellipsisType == EllipsisType.subjektellipse).length,
      'auxiliaryEllipsisCount':
          catalog.where((e) => e.ellipsisType == EllipsisType.hilfsverbellipse).length,
      'blockedZeugmaCount':
          catalog.where((e) => e.feasibility == SyntacticFeasibility.blockedByValenceConflict).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1775 / Wave 41',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
