import '../rent_housing_models.dart';

final class TerminationDepositSubAgent {
  const TerminationDepositSubAgent();

  List<RentHousingEntry> get entries => _entries;

  static const List<RentHousingEntry> _entries = <RentHousingEntry>[
    RentHousingEntry(
      id: 'termination-notice',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Kündigung vorbereiten',
      titleAr: 'تحضير إنهاء عقد الإيجار',
      german:
          'Welche Kündigungsfrist und welche Form stehen in meinem Mietvertrag? Ich möchte die Angaben vor dem Versand prüfen.',
      arabic:
          'ما مهلة وطريقة الإنهاء المذكورتان في عقد الإيجار؟ أريد مراجعة التفاصيل قبل الإرسال.',
      contextDe: 'Vertragsangaben zuerst prüfen und keine allgemeine Frist voraussetzen',
      contextAr: 'مراجعة العقد أولًا وعدم افتراض مهلة عامة غير مكتوبة',
      keywords: <String>['Kündigung', 'Kündigungsfrist', 'Mietvertrag', 'Form'],
    ),
    RentHousingEntry(
      id: 'termination-confirmation',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Kündigung bestätigen lassen',
      titleAr: 'طلب تأكيد إنهاء العقد',
      german:
          'Bitte bestätigen Sie mir den Eingang der Kündigung und das Vertragsende schriftlich.',
      arabic:
          'من فضلك أكّد لي خطيًا استلام إشعار الإنهاء وتاريخ انتهاء العقد.',
      contextDe: 'Eingang und genanntes Vertragsende nachvollziehbar dokumentieren',
      contextAr: 'توثيق استلام الإشعار وتاريخ انتهاء العقد بشكل يمكن الرجوع إليه',
      keywords: <String>['Kündigung', 'schriftlich', 'Bestätigung', 'Vertragsende'],
    ),
    RentHousingEntry(
      id: 'deposit-accounting',
      section: RentHousingSection.contractAndCosts,
      titleDe: 'Kaution nach Auszug',
      titleAr: 'التأمين بعد مغادرة الشقة',
      german:
          'Bitte teilen Sie mir schriftlich mit, wie die Kaution nach Beendigung des Mietverhältnisses abgerechnet wird und ob noch Unterlagen fehlen.',
      arabic:
          'من فضلك أخبرني خطيًا بكيفية تسوية مبلغ التأمين بعد انتهاء الإيجار وما إذا كانت هناك مستندات ناقصة.',
      contextDe: 'Nach Abrechnung und fehlenden Unterlagen fragen, ohne einen Auszahlungszeitpunkt zu versprechen',
      contextAr: 'السؤال عن التسوية والمستندات الناقصة دون افتراض موعد ثابت للاسترداد',
      keywords: <String>['Kaution', 'Abrechnung', 'Auszug', 'schriftlich'],
    ),
  ];
}
