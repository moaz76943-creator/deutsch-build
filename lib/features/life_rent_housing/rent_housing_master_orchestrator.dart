import 'package:flutter/foundation.dart';

import 'rent_housing_models.dart';

final class RentHousingMasterOrchestrator extends ChangeNotifier {
  RentHousingSection _section = RentHousingSection.contractAndCosts;
  String _query = '';

  RentHousingSection get section => _section;
  String get query => _query;

  static const List<RentHousingEntry> _coreEntries = <RentHousingEntry>[
    RentHousingEntry(
      id: 'rent-core-mietvertrag',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Mietvertrag',
      titleAr: 'عقد الإيجار',
      german:
          'Ich möchte den Mietvertrag in Ruhe prüfen. Welche Beträge und Fristen sind hier ausdrücklich vereinbart?',
      arabic:
          'أريد مراجعة عقد الإيجار بهدوء. ما المبالغ والمواعيد المتفق عليها صراحةً هنا؟',
      contextDe:
          'Vertragstext lesen und konkrete Angaben markieren, statt Bedingungen zu erraten',
      contextAr:
          'قراءة نص العقد وتحديد البنود الفعلية بدل افتراض شروط غير مكتوبة',
      keywords: <String>['Mietvertrag', 'Vertrag', 'Frist', 'Kaution'],
    ),
    RentHousingEntry(
      id: 'rent-core-nebenkosten',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Nebenkosten',
      titleAr: 'التكاليف الإضافية',
      german:
          'Welche Nebenkosten sind vereinbart, und welche Vorauszahlungen stehen im Vertrag?',
      arabic:
          'ما التكاليف الإضافية المتفق عليها، وما الدفعات المقدمة المذكورة في العقد؟',
      contextDe:
          'Kaltmiete, Vorauszahlungen und weitere vereinbarte Kosten getrennt erfassen',
      contextAr:
          'فصل الإيجار الأساسي عن الدفعات المقدمة وبقية التكاليف المتفق عليها',
      keywords: <String>[
        'Nebenkosten',
        'Kaltmiete',
        'Warmmiete',
        'Vorauszahlung',
      ],
    ),
    RentHousingEntry(
      id: 'rent-core-uebergabeprotokoll',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Übergabeprotokoll',
      titleAr: 'محضر تسليم واستلام الشقة',
      german:
          'Lassen Sie uns Zustand, Schlüssel und Zählerstände im Übergabeprotokoll festhalten.',
      arabic:
          'دعنا نسجل حالة الشقة والمفاتيح وقراءات العدادات في محضر التسليم.',
      contextDe:
          'Beobachtbare Angaben bei Einzug oder Auszug gemeinsam dokumentieren',
      contextAr:
          'توثيق المعلومات القابلة للملاحظة عند الاستلام أو التسليم',
      keywords: <String>[
        'Übergabeprotokoll',
        'Zählerstand',
        'Schlüssel',
        'Einzug',
        'Auszug',
      ],
    ),
  ];

  List<RentHousingEntry> get visibleEntries => List<RentHousingEntry>.unmodifiable(
        _coreEntries.where(
          (entry) => entry.section == _section && entry.matches(_query),
        ),
      );

  void setSection(RentHousingSection value) {
    if (_section == value) return;
    _section = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');
}
