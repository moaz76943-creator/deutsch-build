import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for apartment viewing and tenancy agreement discussion.
class WohnungssucheScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Herzlich willkommen zur Wohnungsbesichtigung! Kommen Sie bitte herein.',
      utteranceAr: 'أهلاً وسهلاً بكم في موعد معاينة الشقة! تفضلوا بالدخول من فضلكم.',
      linguisticTip: 'Kommen Sie herein = تفضلوا بالدخول.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Vielen Dank. Die Wohnung ist sehr hell und schön geschnitten. Wie hoch ist die Warmmiete?',
      utteranceAr: 'شكراً جزيلاً. الشقة مضيئة ومقسمة بشكل جميل جداً. كم تبلغ قيمة الإيجار الإجمالي الشامل؟',
      linguisticTip: 'Warmmiete = الإيجار الشامل لخدمات التدفئة والمياه (خلاف Kaltmiete).',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Die Kaltmiete beträgt 700 Euro, zuzüglich 180 Euro für die Nebenkosten.',
      utteranceAr: 'الإيجار الصافي 700 يورو، يضاف إليه 180 يورو للمصاريف التشغيلية الإضافية.',
      linguisticTip: 'Nebenkosten = المصاريف التشغيلية للعقار (النظافة، التدفئة، إدارة المبنى).',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Das passt gut. Hier ist meine Selbstauskunft und der Einkommensnachweis.',
      utteranceAr: 'هذا السعر مناسب تماماً. تفضل استمارة بياناتي الشخصية وإثبات الدخل المالي.',
      linguisticTip: 'Selbstauskunft & Einkommensnachweis وثائق أساسية للمفاضلة بين المستأجرين.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Sehr gut. Ihre Unterlagen sind vorbildlich. Ich sende Ihnen den Mietvertrag.',
      utteranceAr: 'ممتاز جداً. أوراقكم مكتملة ومثالية. سأرسل لكم مسودة عقد الإيجار لمراجعتها.',
      linguisticTip: 'Mietvertrag = عقد الإيجار الموثق.',
    ),
  ];
}
