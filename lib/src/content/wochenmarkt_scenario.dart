import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for purchasing fresh seasonal produce at a local German farmers market.
class WochenmarktScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Schönen guten Morgen! Was darf es denn heute Frisches vom Bauernhof sein?',
      utteranceAr: 'صباح الخير والبركة! ما الذي ترغبون باقتنائه اليوم طازجاً من خيرات المزرعة؟',
      linguisticTip: 'Was darf es sein? = السؤال التقليدي الودود للبائعين في الأسواق الألمانية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Morgen. Ich hätte gerne zwei Kilo reife Äpfel und ein Bund frische Minze.',
      utteranceAr: 'صباح الخير. أود من فضلكم كيلوغرامين من التفاح الناضج وباقة من النعناع الأخضر الطازج.',
      linguisticTip: 'ein Bund = حزمة / باقة من الأعشاب أو الخضار الورقية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Sehr gerne. Die Äpfel stammen aus regionalem Bio-Anbau. Darf es noch etwas sein?',
      utteranceAr: 'بكل سرور. هذا التفاح من زراعة عضوية محلية نقية. هل ترغبون بشيء آخر؟',
      linguisticTip: 'regionaler Bio-Anbau = زراعة عضوية محلية عالية الجودة خالية من الكيماويات.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Haben Sie auch frische Feigen oder süße Trauben da?',
      utteranceAr: 'هل يتوفر لديكم أيضاً تين طازج أو عنب حلو المذاق؟',
      linguisticTip: 'die Feigen = التين، die Trauben = العنب.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Ja, diese Feigen sind wunderbar aromatisch. Zusammen macht das genau 9 Euro und 50 Cent.',
      utteranceAr: 'نعم، هذا التين ذو نكهة طيبة جداً. الحساب الإجمالي تسعة يوروهات وخمسون سنتاً.',
      linguisticTip: 'aromatisch = غني بالنكهة الطبيعية الفواحة.',
    ),
  ];
}
