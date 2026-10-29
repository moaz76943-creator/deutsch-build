import '../rent_housing_models.dart';

final class CaretakerSubAgent {
  const CaretakerSubAgent();

  List<RentHousingEntry> get entries => _entries;

  static const List<RentHousingEntry> _entries = <RentHousingEntry>[
    RentHousingEntry(
      id: 'caretaker-appointment',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Termin mit dem Hausmeister',
      titleAr: 'موعد مع حارس البناء',
      german:
          'Könnten Sie bitte einen Termin nennen, an dem Sie sich die Störung ansehen können?',
      arabic:
          'هل يمكنك تحديد موعد تستطيع فيه معاينة العطل من فضلك؟',
      contextDe: 'Einen konkreten Wartungs- oder Besichtigungstermin vereinbaren',
      contextAr: 'الاتفاق على موعد واضح للمعاينة أو الصيانة',
      keywords: <String>['Hausmeister', 'Termin', 'Störung', 'Wartung'],
    ),
    RentHousingEntry(
      id: 'caretaker-access',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Zugang zur Wohnung abstimmen',
      titleAr: 'تنسيق الدخول إلى الشقة',
      german:
          'Bitte klingeln Sie zuerst. Ich bin ab 17 Uhr zu Hause und kann Ihnen dann Zugang zur Wohnung geben.',
      arabic:
          'من فضلك اقرع الجرس أولًا. سأكون في المنزل بعد الخامسة ويمكنني حينها السماح بالدخول إلى الشقة.',
      contextDe: 'Zutritt nur für den abgestimmten Termin klar organisieren',
      contextAr: 'تنظيم الدخول بوضوح ضمن الموعد المتفق عليه',
      keywords: <String>['Hausmeister', 'Zugang', 'Wohnung', 'Termin'],
    ),
    RentHousingEntry(
      id: 'caretaker-follow-up',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Nach Reparaturstand fragen',
      titleAr: 'السؤال عن حالة الإصلاح',
      german:
          'Bitte sagen Sie mir kurz Bescheid, ob ein weiterer Termin oder ein Ersatzteil nötig ist.',
      arabic:
          'من فضلك أخبرني باختصار إذا كان يلزم موعد آخر أو قطعة غيار.',
      contextDe: 'Nach dem aktuellen Reparaturstand und dem nächsten Schritt fragen',
      contextAr: 'السؤال عن وضع الإصلاح الحالي والخطوة التالية',
      keywords: <String>['Reparatur', 'Ersatzteil', 'Hausmeister', 'Status'],
    ),
  ];
}
