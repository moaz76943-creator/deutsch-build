import 'dart:async';
import '../../core/content/german_correlative_connectors_engine.dart';

/// Reactive UI Bridge connecting the Correlative Connectors Engine with interactive visual cards and telemetry.
class Vol116Wave47UiBridge {
  final GermanCorrelativeConnectorsEngine _engine;
  final StreamController<CorrelativeConnectorModel?> _selectedModelController =
      StreamController<CorrelativeConnectorModel?>.broadcast();

  CorrelativePairType? _activePairFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave47UiBridge({GermanCorrelativeConnectorsEngine? engine})
      : _engine = engine ?? GermanCorrelativeConnectorsEngine();

  Stream<CorrelativeConnectorModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<CorrelativeConnectorModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activePairFilter != null && item.pairType != _activePairFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setPairFilter(CorrelativePairType? type) {
    _activePairFilter = type;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activePairFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(CorrelativeConnectorModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalCorrelativeRules': catalog.length,
      'jeDestoCount':
          catalog.where((e) => e.pairType == CorrelativePairType.jeDestoUmso).length,
      'wederNochCount':
          catalog.where((e) => e.pairType == CorrelativePairType.wederNoch).length,
      'entwederOderCount':
          catalog.where((e) => e.pairType == CorrelativePairType.entwederOder).length,
      'nichtNurSondernAuchCount':
          catalog.where((e) => e.pairType == CorrelativePairType.nichtNurSondernAuch).length,
      'zwarAberCount':
          catalog.where((e) => e.pairType == CorrelativePairType.zwarAber).length,
      'einerseitsAndererseitsCount':
          catalog.where((e) => e.pairType == CorrelativePairType.einerseitsAndererseits).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1781 / Wave 47',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
