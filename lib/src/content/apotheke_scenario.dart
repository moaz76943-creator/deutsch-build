import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for redeeming prescriptions, asking about dosage and alcohol-free medication.
class ApothekeScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Willkommen in der Apotheke. Wie kann ich Ihnen helfen?',
      utteranceAr: 'نهاركم سعيد! مرحباً بكم في الصيدلية. كيف يمكنني خدمتكم؟',
      linguisticTip: 'die Apotheke = الصيدلية القانونية للأدوية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ich möchte gerne dieses Rezept vom Arzt einlösen.',
      utteranceAr: 'نهاركم سعيد. أود صرف هذه الوصفة الطبية الصادرة من الطبيب.',
      linguisticTip: 'ein Rezept einlösen = يصرف الروشتة أو الوصفة الطبية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Gerne. Das Medikament ist vorrätig. Nehmen Sie bitte eine Tablette morgens nach dem Essen mit reichlich Wasser ein.',
      utteranceAr: 'بكل سرور. الدواء متوفر في المخزون. يُرجى تناول قرص واحد صباحاً بعد الطعام مع كمية وافرة من الماء.',
      linguisticTip: 'einnehmen = يتناول الدواء، vorrätig = متوفر وموجود في المخزن.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Ist dieses Medikament vollkommen alkoholfrei und ohne bedenkliche Zusatzstoffe?',
      utteranceAr: 'هل هذا الدواء خالٍ تماماً من الكحول ومن أي إضافات تثير القلق؟',
      linguisticTip: 'alkoholfrei = خالٍ تماماً من الكحول، Zusatzstoffe = المواد المضافة.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Ja, absolut unbedenklich und rein pflanzlich. Ich wünsche Ihnen eine rasche und vollständige Genesung!',
      utteranceAr: 'نعم، هو دواء آمن تماماً ومصنوع من مستخلصات نباتية نقية. أتمنى لكم شفاءً عاجلاً وتاماً!',
      linguisticTip: 'die Genesung = الشفاء والتعافي (Gute Besserung).',
    ),
  ];
}
