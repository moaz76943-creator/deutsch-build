import '../rent_housing_models.dart';

final class RentContractSubAgent {
  const RentContractSubAgent();

  List<RentHousingEntry> get entries => _entries;

  static const List<RentHousingEntry> _entries = <RentHousingEntry>[
    RentHousingEntry(
      id: 'contract-kaution',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Kaution im Mietvertrag',
      titleAr: 'التأمين في عقد الإيجار',
      german:
          'Wie hoch ist die Kaution laut Mietvertrag, wann ist sie fällig und wie ist die Zahlung dokumentiert?',
      arabic:
          'كم قيمة التأمين حسب عقد الإيجار، ومتى يستحق، وكيف يتم توثيق الدفع؟',
      contextDe: 'Betrag, Fälligkeit und Zahlungsnachweis aus dem Vertrag erfassen',
      contextAr: 'تسجيل المبلغ وموعد الاستحقاق وإثبات الدفع كما ورد في العقد',
      keywords: <String>['Kaution', 'Mietvertrag', 'Zahlung', 'Fälligkeit'],
    ),
    RentHousingEntry(
      id: 'contract-kaltmiete',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Kaltmiete und Warmmiete unterscheiden',
      titleAr: 'التمييز بين الإيجار البارد والدافئ',
      german:
          'Welche Kaltmiete ist vereinbart, und welche zusätzlichen Beträge ergeben zusammen die Warmmiete?',
      arabic:
          'ما قيمة الإيجار البارد المتفق عليها، وما المبالغ الإضافية التي تكوّن معها الإيجار الدافئ؟',
      contextDe: 'Vertragsbeträge getrennt lesen und nicht pauschal zusammenfassen',
      contextAr: 'قراءة المبالغ في العقد بشكل منفصل وعدم جمعها بافتراضات',
      keywords: <String>[
        'Kaltmiete',
        'Warmmiete',
        'Nebenkosten',
        'Heizkosten',
      ],
    ),
    RentHousingEntry(
      id: 'contract-warmmiete',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Bestandteile der Warmmiete',
      titleAr: 'مكوّنات الإيجار الدافئ',
      german:
          'Bitte zeigen Sie mir, welche Nebenkosten und Vorauszahlungen in der angegebenen Warmmiete enthalten sind.',
      arabic:
          'من فضلك وضّح لي ما التكاليف الإضافية والدفعات المقدمة الداخلة في مبلغ الإيجار الدافئ المذكور.',
      contextDe: 'Nur die im konkreten Vertrag genannten Bestandteile übernehmen',
      contextAr: 'اعتماد المكونات المذكورة في العقد الفعلي فقط',
      keywords: <String>['Warmmiete', 'Nebenkosten', 'Vorauszahlung', 'Vertrag'],
    ),
  ];
}
