import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for health insurance card issuance and choosing a family doctor.
class KrankenkasseHausarztScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Willkommen bei Ihrer gesetzlichen Krankenkasse. Wie kann ich Sie versichern?',
      utteranceAr: 'نهاركم سعيد! أهلاً بكم في صندوق التأمين الصحي القانوني. كيف يمكنني إتمام إجراءات تأمينكم؟',
      linguisticTip: 'die gesetzliche Krankenkasse (GKV) = التأمين الصحي القانوني الشامل في ألمانيا.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ich beginne nächste Woche eine neue Arbeitsstelle und benötige die elektronische Gesundheitskarte.',
      utteranceAr: 'نهاركم سعيد. سأبدأ الأسبوع القادم وظيفة عمل جديدة وأحتاج إلى بطاقة التأمين الصحي الإلكترونية.',
      linguisticTip: 'die elektronische Gesundheitskarte (eGK) = بطاقة التأمين الصحي الذكية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Sehr gerne. Wir aktivieren Ihren Schutz sofort. Empfehlenswert ist auch die Einschreibung ins Hausarztprogramm.',
      utteranceAr: 'بكل سرور. سنفعل تغطيتكم التأمينية فوراً. ونوصيكم أيضاً بالتسجيل في برنامج طبيب الأسرة.',
      linguisticTip: 'das Hausarztprogramm = برنامج طبيب الأسرة لتنسيق العلاج الطبي المتكامل.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Welche Vorteile bietet die feste Betreuung durch einen Hausarzt?',
      utteranceAr: 'ما هي المزايا والفوائد التي يوفرها المتابعة الثابتة لدى طبيب الأسرة؟',
      linguisticTip: 'der Hausarzt = طبيب الأسرة / الطبيب العام المعني بالرعاية الصحية الأولية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Ihr Hausarzt koordiniert alle Facharzttermine, kennt Ihre Krankengeschichte und vermeidet Doppeluntersuchungen.',
      utteranceAr: 'طبيب أسرتكم ينسق جميع مواعيد الأطباء التخصصيين، ويكون مطلعاً على تاريخكم الصحي ويتفادى الفحوصات المتكررة غير الضرورية.',
      linguisticTip: 'der Facharzt = الطبيب الأخصائي (مثل أخصائي العيون أو القلب).',
    ),
  ];
}
