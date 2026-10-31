import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for vehicle roadworthiness inspection (TÜV) and transparent workshop service.
class TuevAutowerkstattScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Kfz-Meisterwerkstatt, guten Tag! Welche Wartung oder Prüfung steht für Ihr Fahrzeug an?',
      utteranceAr: 'ورشة الميكانيك المعتمدة للسيارات، نهاركم سعيد! ما هي الصيانة أو الفحوصات المقررة لسيارتكم؟',
      linguisticTip: 'die Kfz-Werkstatt = ورشة صيانة وتصليح السيارات المعتمدة.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Bei meinem Auto ist die Hauptuntersuchung für die TÜV-Plakette in diesem Monat fällig.',
      utteranceAr: 'نهاركم سعيد. سيارتي مستحقة هذا الشهر لإجراء الفحص الفني الدوري الشامل للحصول على ملصق السلامة (TÜV).',
      linguisticTip: 'die Hauptuntersuchung (HU/TÜV) = الفحص الفني الدوري الإلزامي للسلامة المرورية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Wir führen vor der offiziellen Abnahme einen gründlichen Vorab-Check der Bremsen, Beleuchtung und Reifen durch.',
      utteranceAr: 'نقوم قبل الفحص الرسمي بفحص تمهيدي دقيق لمنظومة المكابح والإضاءة وحالة الإطارات.',
      linguisticTip: 'der Vorab-Check = الفحص التمهيدي لتفادي أي ملاحظات أو رسوب.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Sehr gut. Bitte informieren Sie mich vorab telefonisch, falls Teile ausgetauscht werden müssen.',
      utteranceAr: 'ممتاز جداً. يُرجى إبلاغي هاتفياً مسبقاً في حال استدعى الأمر استبدال أي قطع غيار.',
      linguisticTip: 'vorab telefonisch informieren = إبلاغ العميل مسبقاً حفاظاً على الشفافية المالية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Selbstverständlich. Transparenz und Verkehrssicherheit haben bei uns oberste Priorität. Ihr Wagen ist heute Nachmittag abholbereit.',
      utteranceAr: 'بكل تأكيد. الشفافية التامة والسلامة المرورية هما أولويتنا القصوى. سيارتكم ستكون جاهزة للاستلام بعد ظهر اليوم.',
      linguisticTip: 'abholbereit = جاهز للتسليم والاستلام.',
    ),
  ];
}
