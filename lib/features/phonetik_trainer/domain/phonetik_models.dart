enum PhonetikTopic {
  ichAch,
  umlautA,
  umlautO,
  umlautU,
  spSt,
  stressIntonation,
}

final class PhonetikExample {
  const PhonetikExample({
    required this.word,
    required this.ipa,
    required this.hintAr,
  });

  final String word;
  final String ipa;
  final String hintAr;
}

final class PhonetikExercise {
  const PhonetikExercise({
    required this.promptAr,
    required this.choices,
    required this.correctChoice,
    required this.explanationAr,
  });

  final String promptAr;
  final List<String> choices;
  final String correctChoice;
  final String explanationAr;
}

final class PhonetikFocus {
  const PhonetikFocus({
    required this.id,
    required this.topic,
    required this.titleDe,
    required this.titleAr,
    required this.articulationAr,
    required this.examples,
    required this.exercise,
  });

  final String id;
  final PhonetikTopic topic;
  final String titleDe;
  final String titleAr;
  final String articulationAr;
  final List<PhonetikExample> examples;
  final PhonetikExercise exercise;
}

final class PhonetikAnswerResult {
  const PhonetikAnswerResult({
    required this.isCorrect,
    required this.selectedChoice,
    required this.expectedChoice,
    required this.feedbackAr,
  });

  final bool isCorrect;
  final String selectedChoice;
  final String expectedChoice;
  final String feedbackAr;
}
