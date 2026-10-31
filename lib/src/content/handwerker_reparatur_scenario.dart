import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for reporting household malfunctions and coordinating craftsman repairs.
class HandwerkerReparaturScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Hausverwaltung Kundenservice, guten Tag! Welcher Reparaturbedarf liegt in Ihrer Wohnung vor?',
      utteranceAr: 'خدمة عملاء إدارة العقارات السكنية، نهاركم سعيد! ما هو العطل أو الإصلاح المطلوب في شقتكم؟',
      linguisticTip: 'die Hausverwaltung = شركة إدارة العقارات السكنية المسؤولة عن صيانة المبنى.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Die Heizung im Wohnzimmer bleibt leider kalt und das Thermostatventil lässt sich nicht mehr drehen.',
      utteranceAr: 'نهاركم سعيد. التدفئة في غرفة المعيشة للأسف لا تسخن مطلقاً وصمام التحكم الآلي (الثرموستات) توقف عن الدوران.',
      linguisticTip: 'die Heizung = جهاز التدفئة المركزية، das Thermostat = صمام ضبط الحرارة.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Vielen Dank für die Meldung. Wir beauftragen unverzüglich einen zertifizierten Heizungsinstallateur.',
      utteranceAr: 'شكراً لكم على إبلاغنا. سنكلف على الفور فنياً مختصاً ومعتمداً في تمديدات التدفئة لإصلاح الخلل.',
      linguisticTip: 'der Installateur = الفني التقني المختص في التمديدات والتدفئة والصحية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Wann kann der Handwerker vorbeikommen? Ich bin morgen Vormittag zu Hause erreichbar.',
      utteranceAr: 'متى يمكن للحرفي زيارة الشقة؟ سأكون متواجداً في المنزل قبل ظهر الغد لاستقباله.',
      linguisticTip: 'vorbeikommen = يمر لزيارة المكان / يعاين العطل.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Der Handwerker kommt morgen zwischen 9 und 11 Uhr. Die Reparaturkosten übernimmt selbstverständlich der Eigentümer.',
      utteranceAr: 'سيحضر الفني غداً بين الساعة التاسعة والحادية عشرة صباحاً. وتكاليف الإصلاح يتحملها مالك العقار قانونياً.',
      linguisticTip: 'die Reparaturkosten übernehmen = يتحمل تكاليف الصيانة والإصلاح.',
    ),
  ];
}
