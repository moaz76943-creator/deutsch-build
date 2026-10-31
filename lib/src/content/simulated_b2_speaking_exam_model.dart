/// Model simulating B2 Speaking exam (Teil 2: Eine Diskussion führen / Partner Debate).
class DebateDiscussionTopic {
  final String titleDe;
  final String titleAr;
  final List<String> proArgumentsDe;
  final List<String> contraArgumentsDe;
  final List<String> conversationalRedemittelDe;
  final String pedagogicalGuidanceAr;

  const DebateDiscussionTopic({
    required this.titleDe,
    required this.titleAr,
    required this.proArgumentsDe,
    required this.contraArgumentsDe,
    required this.conversationalRedemittelDe,
    required this.pedagogicalGuidanceAr,
  });
}

/// Simulated B2 Speaking module covering dialectical debate, rebuttal, and consensual agreement.
class SimulatedB2SpeakingExamModel {
  static const DebateDiscussionTopic homeofficeDebate = DebateDiscussionTopic(
    titleDe: 'Homeoffice und ortsunabhängiges Arbeiten: Fluch oder Segen?',
    titleAr: 'العمل عن بُعد ومن المنزل: هل هو نعمة أم نقمة؟',
    proArgumentsDe: [
      'Zeitersparnis durch Wegfall des täglichen Arbeitsweges im Berufsverkehr.',
      'Bessere Vereinbarkeit von Familie und Beruf.',
      'Höhere Konzentration bei anspruchsvollen analytischen Aufgaben.',
    ],
    contraArgumentsDe: [
      'Gefahr der sozialen Isolation und Mangel an direktem kollegialem Austausch.',
      'Verschwimmen der Grenzen zwischen Arbeitszeit und wohlverdienter Erholungsphase.',
    ],
    conversationalRedemittelDe: [
      'Da stimme ich Ihnen vollkommen zu, allerdings sollte man bedenken, dass...',
      'Einerseits bietet dies große Flexibilität, andererseits birgt es die Gefahr...',
      'Ich verstehe Ihren Standpunkt, bin jedoch der Auffassung, dass...',
    ],
    pedagogicalGuidanceAr:
      'معايير B2 في النقاش تتطلب استخدام الروابط الجدلية المتقدمة (Einerseits... andererseits) والرد المهذب على حجج الشريك دون مقاطعة حادة.',
  );
}
