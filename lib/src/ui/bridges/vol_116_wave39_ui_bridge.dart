import 'dart:async';
import '../../core/content/german_circumposition_engine.dart';

/// Reactive UI Bridge connecting the Circumposition Engine with the UI layer.
class Vol116Wave39UiBridge {
  final GermanCircumpositionEngine _engine;
  final StreamController<CircumpositionModel?> _selectionController =
      StreamController<CircumpositionModel?>.broadcast();

  PositionalType? _activeTypeFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave39UiBridge({GermanCircumpositionEngine? engine})
      : _engine = engine ?? GermanCircumpositionEngine();

  Stream<CircumpositionModel?> get selectedModelStream =>
      _selectionController.stream;

  List<CircumpositionModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeTypeFilter != null && item.positionalType != _activeTypeFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(PositionalType? type) {
    _activeTypeFilter = type;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeTypeFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(CircumpositionModel model) {
    _selectionController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalAdpositionRules': catalog.length,
      'circumpositionCount':
          catalog.where((e) => e.positionalType == PositionalType.circumposition).length,
      'postpositionCount':
          catalog.where((e) => e.positionalType == PositionalType.postposition).length,
      'ambipositionCount':
          catalog.where((e) => e.positionalType == PositionalType.ambiposition).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1773 / Wave 39',
    };
  }

  void dispose() {
    _selectionController.close();
  }
}
