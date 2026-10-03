import '../rent_housing_models.dart';

final class DefectNoticeSubAgent {
  const DefectNoticeSubAgent();

  List<RentHousingEntry> get entries => _entries;

  static const List<RentHousingEntry> _entries = <RentHousingEntry>[
    RentHousingEntry(
      id: 'defect-heating',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Heizung ausgefallen',
      titleAr: 'تعطل التدفئة',
      german:
          'Die Heizung funktioniert seit heute Morgen nicht. Bitte teilen Sie mir mit, wann die Störung geprüft werden kann.',
      arabic:
          'التدفئة لا تعمل منذ هذا الصباح. من فضلك أخبرني متى يمكن فحص العطل.',
      contextDe: 'Zeitpunkt, betroffenen Bereich und konkrete Störung nennen',
      contextAr: 'ذكر وقت بدء المشكلة والمكان المتأثر والعطل بشكل محدد',
      keywords: <String>['Heizung', 'Ausfall', 'Störung', 'Mängelrüge'],
    ),
    RentHousingEntry(
      id: 'defect-mould',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Schimmel melden',
      titleAr: 'الإبلاغ عن العفن',
      german:
          'Ich habe Schimmel an der Wand im Schlafzimmer festgestellt. Bitte bestätigen Sie den Eingang meiner Meldung und die nächsten Schritte.',
      arabic:
          'لاحظت وجود عفن على جدار غرفة النوم. من فضلك أكّد استلام البلاغ وأخبرني بالخطوات التالية.',
      contextDe: 'Ort und beobachtbaren Zustand beschreiben, ohne Ursache zu behaupten',
      contextAr: 'وصف الموقع والحالة الظاهرة دون افتراض سبب المشكلة',
      keywords: <String>['Schimmel', 'Wand', 'Mängelrüge', 'Meldung'],
    ),
    RentHousingEntry(
      id: 'defect-water-leak',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Wasserleck melden',
      titleAr: 'الإبلاغ عن تسريب مياه',
      german:
          'Unter dem Waschbecken tritt Wasser aus. Bitte veranlassen Sie eine Prüfung und teilen Sie mir den möglichen Termin mit.',
      arabic:
          'يوجد تسرب للمياه تحت المغسلة. من فضلك رتّب فحص المشكلة وأخبرني بالموعد الممكن.',
      contextDe: 'Leckstelle und sichtbare Auswirkung knapp dokumentieren',
      contextAr: 'وصف مكان التسريب وأثره الظاهر باختصار',
      keywords: <String>['Wasser', 'Leck', 'Waschbecken', 'Mängelrüge'],
    ),
  ];
}
