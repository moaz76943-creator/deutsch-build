/// Model simulating C1 Oral Examination (Teil 1: Freier Vortrag zu einem wissenschaftlichen Thema).
class AcademicPresentationTopic {
  final String titleDe;
  final String titleAr;
  final List<String> requiredDimensionsDe;
  final List<String> advancedRedemittelDe;
  final String evaluationCriteriaAr;

  const AcademicPresentationTopic({
    required this.titleDe,
    required this.titleAr,
    required this.requiredDimensionsDe,
    required this.advancedRedemittelDe,
    required this.evaluationCriteriaAr,
  });
}

/// Simulated C1 Speaking module covering scholarly discourse and defense of thesis.
class SimulatedC1SpeakingExamModel {
  static const AcademicPresentationTopic energyTransitionTopic = AcademicPresentationTopic(
    titleDe: 'Ökologische Nachhaltigkeit und industrielle Transformation',
    titleAr: 'الاستدامة البيئية والتحول الصناعي نحو الاقتصاد الأخضر',
    requiredDimensionsDe: [
      'Problemaufriss: Ressourcenknappheit und globale Klimaverantwortung.',
      'Technologische Lösungsansätze: Grüner Wasserstoff und Kreislaufwirtschaft.',
      'Ökonomische Implikationen für den Mittelstand.',
      'Kritisches Fazit und Ausblick.',
    ],
    advancedRedemittelDe: [
      'Im Zentrum meiner Betrachtung steht die Frage, inwieweit...',
      'Zur Untermauerung dieser These lässt sich anführen, dass...',
      'Es darf keineswegs verkannt werden, dass...',
      'Daraus resultiert zwingend die Notwendigkeit...',
    ],
    evaluationCriteriaAr:
      'معايير C1 الشفهية تركز على الطلاقة اللغوية الفائقة، وتنوع التراكيب النحوية المعقدة (Passiv, Konjunktiv I/II)، والقدرة على تفنيد الحجج المضادة بأسلوب أكاديمي رصين.',
  );
}
