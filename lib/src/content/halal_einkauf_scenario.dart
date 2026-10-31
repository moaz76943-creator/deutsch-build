import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for verifying halal food ingredients and respectful grocery interaction.
class HalalEinkaufScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Kann ich Ihnen bei der Auswahl der Lebensmittel behilflich sein?',
      utteranceAr: 'نهاركم سعيد! هل يمكنني مساعدتكم في اختيار المواد الغذائية؟',
      linguisticTip: 'behilflich sein = يقدم المساعدة بلباقة.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ich suche Lebensmittel ohne tierische Gelatine und ohne Alkohol. Haben Sie zertifizierte Produkte?',
      utteranceAr: 'نهاركم سعيد. أبحث عن منتجات غذائية خالية من الجيلاتين الحيواني ومن الكحول. هل تتوفر لديكم منتجات معتمدة؟',
      linguisticTip: 'ohne + Akkusativ (ohne tierische Gelatine / ohne Alkohol).',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Ja, selbstverständlich. In diesem Regal finden Sie rein pflanzliche und halal-zertifizierte Artikel.',
      utteranceAr: 'نعم بكل تأكيد. في هذا الرف تجدون منتجات نباتية خالصة ومواد معتمدة حلالاً.',
      linguisticTip: 'rein pflanzlich = نباتي نقي وخالٍ من المشتقات الحيوانية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Vielen Dank für die Auskunft. Ich nehme zwei Packungen von diesen Datteln und Bio-Olivenöl.',
      utteranceAr: 'شكراً جزيلاً لكم على التوضيح. سآخذ علبتين من هذا التمر وزيت زيتون عضوي.',
      linguisticTip: 'Ich nehme = سآخذ / أختار في سياق الشراء.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Sehr gerne. Das macht zusammen 14 Euro. Zahlen Sie bar oder mit Karte?',
      utteranceAr: 'بكل سرور. الحساب الإجمالي 14 يورو. هل تفضلون الدفع نقداً أم بالبطاقة؟',
      linguisticTip: 'bar zahlen = الدفع نقداً، mit Karte = بالبطاقة المصرفية.',
    ),
  ];
}
