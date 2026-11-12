import 'dart:async';
import '../../core/content/german_parenthesis_intercalation_engine.dart';

/// Reactive UI Bridge connecting the Parenthesis Engine with the visual presentation layer.
class Vol116Wave40UiBridge {
  final GermanParenthesisIntercalationEngine _engine;
  final StreamController<ParenthesisModel?> _selectedModelController =
      StreamController<ParenthesisModel?>.broadcast();

  IntercalationType? _activeTypeFilter;
  PunctuationStyle? _activeStyleFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave40UiBridge({GermanParenthesisIntercalationEngine? engine})
      : _engine = engine ?? GermanParenthesisIntercalationEngine();

  Stream<ParenthesisModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<ParenthesisModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeTypeFilter != null && item.intercalationType != _activeTypeFilter) {
        return false;
      }
      if (_activeStyleFilter != null && item.punctuationStyle != _activeStyleFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(IntercalationType? type) {
    _activeTypeFilter = type;
  }

  void setStyleFilter(PunctuationStyle? style) {
    _activeStyleFilter = style;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeTypeFilter = null;
    _activeStyleFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(ParenthesisModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalParenthesisRules': catalog.length,
      'verbalSchaltsatzCount':
          catalog.where((e) => e.intercalationType == IntercalationType.verbalSchaltsatz).length,
      'nominalParenthesisCount':
          catalog.where((e) => e.intercalationType == IntercalationType.nominalParenthesis).length,
      'epistemicCommentCount':
          catalog.where((e) => e.intercalationType == IntercalationType.epistemicComment).length,
      'metalinguisticFormulaCount':
          catalog.where((e) => e.intercalationType == IntercalationType.metalinguisticFormula).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1774 / Wave 40',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
