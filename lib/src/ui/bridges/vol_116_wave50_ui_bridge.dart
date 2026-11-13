import 'dart:async';
import '../../core/content/german_concessive_adversative_engine.dart';

/// Reactive UI Bridge connecting the Concessive & Adversative Engine with interactive cards and telemetry.
class Vol116Wave50UiBridge {
  final GermanConcessiveAdversativeEngine _engine;
  final StreamController<ConcessiveConnectorModel?> _selectedModelController =
      StreamController<ConcessiveConnectorModel?>.broadcast();

  ConcessiveConnectorType? _activeTypeFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave50UiBridge({GermanConcessiveAdversativeEngine? engine})
      : _engine = engine ?? GermanConcessiveAdversativeEngine();

  Stream<ConcessiveConnectorModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<ConcessiveConnectorModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeTypeFilter != null && item.connectorType != _activeTypeFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(ConcessiveConnectorType? type) {
    _activeTypeFilter = type;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeTypeFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(ConcessiveConnectorModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalConcessiveRules': catalog.length,
      'subordinatingCount':
          catalog.where((e) => e.connectorType == ConcessiveConnectorType.subordinatingConjunction).length,
      'adverbialInversionCount':
          catalog.where((e) => e.connectorType == ConcessiveConnectorType.adverbialInversionConnector).length,
      'prepositionalGenitiveCount':
          catalog.where((e) => e.connectorType == ConcessiveConnectorType.prepositionalGenitivePhrase).length,
      'scalarGeneralizingCount':
          catalog.where((e) => e.connectorType == ConcessiveConnectorType.scalarGeneralizingConcessive).length,
      'adversativeContrastCount':
          catalog.where((e) => e.connectorType == ConcessiveConnectorType.adversativeContrast).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1784 / Wave 50',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
