import 'package:flutter/foundation.dart';

import 'diy_models.dart';
import 'hardware_store_sub_agent.dart';
import 'tool_rental_sub_agent.dart';

final class DiyMasterOrchestrator extends ChangeNotifier {
  DiyMasterOrchestrator({
    HardwareStoreSubAgent hardwareStore = const HardwareStoreSubAgent(),
    ToolRentalSubAgent toolRental = const ToolRentalSubAgent(),
  })  : _hardwareStore = hardwareStore,
        _toolRental = toolRental;

  final HardwareStoreSubAgent _hardwareStore;
  final ToolRentalSubAgent _toolRental;

  DiyDomain _domain = DiyDomain.materialsHardware;
  String _query = '';
  double _conversionValue = 1000;
  DiyLengthUnit _fromUnit = DiyLengthUnit.millimeter;
  DiyLengthUnit _toUnit = DiyLengthUnit.meter;
  int _screwDiameterMm = 5;

  DiyDomain get domain => _domain;
  String get query => _query;
  double get conversionValue => _conversionValue;
  DiyLengthUnit get fromUnit => _fromUnit;
  DiyLengthUnit get toUnit => _toUnit;
  int get screwDiameterMm => _screwDiameterMm;

  List<DiyPhrase> get visiblePhrases {
    final source = switch (_domain) {
      DiyDomain.materialsHardware => _hardwareStore.phrases,
      DiyDomain.servicesRental => _toolRental.phrases,
    };

    return List<DiyPhrase>.unmodifiable(
      source.where((phrase) => phrase.matches(_query)),
    );
  }

  double get convertedValue => _conversionValue *
      _fromUnit.metersPerUnit /
      _toUnit.metersPerUnit;

  String get formattedInputValue => _formatNumber(_conversionValue);

  String get formattedConversion {
    final value = convertedValue;
    return '${_formatNumber(value)} ${_toUnit.symbol}';
  }

  DiySizingPrompt get sizingPrompt => DiySizingPrompt(
        german:
            'Ich habe eine Schraube mit $_screwDiameterMm mm Durchmesser. Welcher Dübel ist laut Herstellerangabe für meinen Untergrund passend?',
        arabic:
            'لدي برغي بقطر $_screwDiameterMm مم. ما قطعة التثبيت المناسبة لهذا السطح حسب تعليمات الشركة المصنّعة؟',
      );

  static String _formatNumber(double value) {
    final fixed = value.toStringAsFixed(3);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void setDomain(DiyDomain value) {
    if (_domain == value) return;
    _domain = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  void setConversionValue(double value) {
    if (!value.isFinite || value < 0 || _conversionValue == value) return;
    _conversionValue = value;
    notifyListeners();
  }

  void setFromUnit(DiyLengthUnit value) {
    if (_fromUnit == value) return;
    _fromUnit = value;
    notifyListeners();
  }

  void setToUnit(DiyLengthUnit value) {
    if (_toUnit == value) return;
    _toUnit = value;
    notifyListeners();
  }

  void setScrewDiameterMm(int value) {
    if (value <= 0 || _screwDiameterMm == value) return;
    _screwDiameterMm = value;
    notifyListeners();
  }
}
