/// Task specifications for A2 collaborative planning oral exam (Gemeinsam etwas planen).
class JointPlanningTask {
  final String scenarioTitle;
  final String objective;
  final List<String> discussionPoints;
  final List<String> suggestedPhrasesDe;
  final String pedagogicalGuidanceAr;

  const JointPlanningTask({
    required this.scenarioTitle,
    required this.objective,
    required this.discussionPoints,
    required this.suggestedPhrasesDe,
    required this.pedagogicalGuidanceAr,
  });
}

/// Simulated A2 Speaking module covering personal experiences and collaborative decision-making.
class SimulatedA2SpeakingExamModel {
  static const JointPlanningTask parkCleanUpPlan = JointPlanningTask(
    scenarioTitle: 'Gemeinsamer Ausflug in den Stadtpark',
    objective: 'Planen Sie zusammen mit Ihrer Prüfungspartnerin einen gemeinsamen Samstagsausflug.',
    discussionPoints: [
      'Wann treffen wir uns? (Uhrzeit und Treffpunkt)',
      'Wie fahren wir dorthin? (Fahrrad oder Bus)',
      'Was nehmen wir mit? (Obst, Wasser, Decke, Buch)',
      'Was machen wir bei schlechtem Wetter? (Museumsbesuch)',
    ],
    suggestedPhrasesDe: [
      'Ich schlage vor, dass wir...',
      'Was hältst du davon, wenn wir...?',
      'Das ist eine hervorragende Idee!',
      'Am Samstag passt es mir leider nicht so gut, wie wäre es mit...',
    ],
    pedagogicalGuidanceAr:
      'معيار التقييم في A2 يعتمد على التفاعل والمبادرة باقتراحات والاستماع باهتمام لرأي الشريك مع التوصل لاتفاق مشترك.',
  );
}
