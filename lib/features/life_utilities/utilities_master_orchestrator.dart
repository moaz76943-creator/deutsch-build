import 'package:flutter/foundation.dart';

import 'energy_contracts_sub_agent.dart';
import 'meter_and_invoice_sub_agent.dart';
import 'utilities_models.dart';

final class UtilitiesMasterOrchestrator extends ChangeNotifier {
  UtilitiesMasterOrchestrator({
    MeterAndInvoiceSubAgent meterAndInvoice =
        const MeterAndInvoiceSubAgent(),
    EnergyContractsSubAgent energyContracts =
        const EnergyContractsSubAgent(),
  })  : _meterAndInvoice = meterAndInvoice,
        _energyContracts = energyContracts;

  final MeterAndInvoiceSubAgent _meterAndInvoice;
  final EnergyContractsSubAgent _energyContracts;

  UtilitiesCategory _category =
      UtilitiesCategory.meterReadingsInvoices;
  String _query = '';

  UtilitiesCategory get category => _category;
  String get query => _query;

  UtilitiesPhrase get quickMeterReadingGuide =>
      _meterAndInvoice.quickMeterReadingGuide;

  List<UtilitiesPhrase> get visiblePhrases {
    final source = switch (_category) {
      UtilitiesCategory.meterReadingsInvoices =>
        _meterAndInvoice.phrases,
      UtilitiesCategory.contractsSwitching =>
        _energyContracts.phrases,
    };

    return List<UtilitiesPhrase>.unmodifiable(
      source.where((phrase) => phrase.matches(_query)),
    );
  }

  void setCategory(UtilitiesCategory value) {
    if (_category == value && _query.isEmpty) return;

    _category = value;
    _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    final normalized = value.trim();
    if (_query == normalized) return;

    _query = normalized;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  void openQuickMeterReadingGuide() {
    const quickQuery = 'Zählerstand melden';
    final changed =
        _category != UtilitiesCategory.meterReadingsInvoices ||
        _query != quickQuery;

    _category = UtilitiesCategory.meterReadingsInvoices;
    _query = quickQuery;

    if (changed) notifyListeners();
  }
}
