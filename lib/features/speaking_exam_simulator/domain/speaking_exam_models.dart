enum ExamProvider { goethe, telc }

enum ExamLevel { b1, b2 }

enum SpeakingPhaseType {
  preparation,
  presentation,
  partnerQuestions,
  discussion,
  jointPlanning,
  wrapUp,
}

enum DebateStance { pro, contra, balanced }

final class SpeakingPhaseConfig {
  const SpeakingPhaseConfig({
    required this.type,
    required this.titleDe,
    required this.titleAr,
    required this.duration,
    required this.guidanceAr,
  });

  final SpeakingPhaseType type;
  final String titleDe;
  final String titleAr;
  final Duration duration;
  final String guidanceAr;
}

final class SpeakingExamScenario {
  const SpeakingExamScenario({
    required this.id,
    required this.provider,
    required this.level,
    required this.topicDe,
    required this.topicAr,
    required this.presentationPromptDe,
    required this.presentationPointsDe,
    required this.presentationPointsAr,
    required this.debateStatementDe,
    required this.debateStatementAr,
    required this.proArgumentsDe,
    required this.contraArgumentsDe,
    required this.partnerQuestionsDe,
    required this.planningTaskDe,
    required this.planningTaskAr,
    required this.phases,
  });

  final String id;
  final ExamProvider provider;
  final ExamLevel level;
  final String topicDe;
  final String topicAr;
  final String presentationPromptDe;
  final List<String> presentationPointsDe;
  final List<String> presentationPointsAr;
  final String debateStatementDe;
  final String debateStatementAr;
  final List<String> proArgumentsDe;
  final List<String> contraArgumentsDe;
  final List<String> partnerQuestionsDe;
  final String planningTaskDe;
  final String planningTaskAr;
  final List<SpeakingPhaseConfig> phases;

  String get providerLabel => switch (provider) {
        ExamProvider.goethe => 'Goethe',
        ExamProvider.telc => 'telc',
      };

  String get levelLabel => switch (level) {
        ExamLevel.b1 => 'B1',
        ExamLevel.b2 => 'B2',
      };
}
