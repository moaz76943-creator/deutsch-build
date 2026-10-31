import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for a professional job interview in Germany.
class BewerbungsgespraechScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Herzlich willkommen zu unserem Gespräch! Erzählen Sie uns bitte kurz über Ihren Werdegang.',
      utteranceAr: 'أهلاً وسهلاً بكم في لقائنا! هل تفضلتم بتقديم نبذة موجزة عن مسيرتكم المهنية؟',
      linguisticTip: 'der Werdegang = المسار المهني والسيرة العملية للمرشح.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Sehr gerne. Ich habe Informatik studiert und verfüge über mehrjährige Berufserfahrung in Softwareprojekten.',
      utteranceAr: 'بكل سرور. درست علوم الحاسوب ولديّ خبرة عملية لعدة سنوات في مشاريع برمجية متنوعة.',
      linguisticTip: 'verfügen über + Akkusativ = يمتلك / لديه في رصيده المهني.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Das klingt überzeugend. Welche Stärken zeichnen Ihre tägliche Arbeitsweise besonders aus?',
      utteranceAr: 'هذا يبدو مقنعاً وممتازاً. ما هي نقاط القوة التي تميز أسلوب عملكم اليومي بشكل خاص؟',
      linguisticTip: 'die Stärken = نقاط القوة والتميز المهني.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Zuverlässigkeit, analytisches Denken und eine hohe Bereitschaft zur konstruktiven Teamarbeit.',
      utteranceAr: 'الأمانة والموثوقية، والتفكير التحليلي المنطقي، والاستعداد العالي للعمل الجماعي البناء.',
      linguisticTip: 'صفات مهنية تحظى بتقدير كبير في بيئة العمل الألمانية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Vielen Dank für das angenehme Gespräch. Wir melden uns bis Ende der Woche bei Ihnen.',
      utteranceAr: 'شكراً جزيلاً لكم على هذا الحوار الطيب. سنتواصل معكم رسمياً قبل نهاية الأسبوع.',
      linguisticTip: 'sich melden bei = يتواصل مع / يقدم رداً رسمياً.',
    ),
  ];
}
