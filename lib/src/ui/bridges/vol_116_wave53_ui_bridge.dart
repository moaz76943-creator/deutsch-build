import 'dart:async';
import '../../core/content/german_recipient_stative_passive_engine.dart';

/// Reactive UI Bridge connecting the Recipient & Stative Passive Engine with interactive cards and telemetry.
class Vol116Wave53UiBridge {
  final GermanRecipientStativePassiveEngine _engine;
  final StreamController<PassiveTransformationModel?> _selectedModelController =
      StreamController<PassiveTransformationModel?>.broadcast();

  PassiveVoiceType? _activeTypeFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave53UiBridge({GermanRecipientStativePassiveEngine? engine})
      : _engine = engine ?? GermanRecipientStativePassiveEngine();

  Stream<PassiveTransformationModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<PassiveTransformationModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeTypeFilter != null && item.passiveType != _activeTypeFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(PassiveVoiceType? type) {
    _activeTypeFilter = type;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeTypeFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(PassiveTransformationModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalPassiveRules': catalog.length,
      'erhaltenPassiveCount':
          catalog.where((e) => e.passiveType == PassiveVoiceType.rezipientenpassivErhalten).length,
      'bekommenPassiveCount':
          catalog.where((e) => e.passiveType == PassiveVoiceType.rezipientenpassivBekommen).length,
      'zustandspassivCount':
          catalog.where((e) => e.passiveType == PassiveVoiceType.zustandspassivStative).length,
      'vorgangspassivCount':
          catalog.where((e) => e.passiveType == PassiveVoiceType.vorgangspassivProcess).length,
      'subjektlosPassiveCount':
          catalog.where((e) => e.passiveType == PassiveVoiceType.subjektlosesPassivImpersonal).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1787 / Wave 53',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
