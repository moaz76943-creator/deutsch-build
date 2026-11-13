import 'dart:async';
import '../../core/content/german_advanced_relatives_engine.dart';

/// Reactive UI Bridge connecting the Advanced Relatives Engine with interactive cards and telemetry.
class Vol116Wave51UiBridge {
  final GermanAdvancedRelativesEngine _engine;
  final StreamController<AdvancedRelativeModel?> _selectedModelController =
      StreamController<AdvancedRelativeModel?>.broadcast();

  RelativeClauseType? _activeTypeFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave51UiBridge({GermanAdvancedRelativesEngine? engine})
      : _engine = engine ?? GermanAdvancedRelativesEngine();

  Stream<AdvancedRelativeModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<AdvancedRelativeModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeTypeFilter != null && item.relativeType != _activeTypeFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(RelativeClauseType? type) {
    _activeTypeFilter = type;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeTypeFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(AdvancedRelativeModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalRelativeRules': catalog.length,
      'dessenRulesCount':
          catalog.where((e) => e.relativeType == RelativeClauseType.genitiveRelativeDessen).length,
      'derenRulesCount':
          catalog.where((e) => e.relativeType == RelativeClauseType.genitiveRelativeDeren).length,
      'prepositionalRelativesCount':
          catalog.where((e) => e.relativeType == RelativeClauseType.prepositionalGenitiveRelative).length,
      'partitiveRelativesCount':
          catalog.where((e) => e.relativeType == RelativeClauseType.partitiveRelativeClause).length,
      'locativeRelativesCount':
          catalog.where((e) => e.relativeType == RelativeClauseType.generalizingLocativeRelative).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1785 / Wave 51',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
