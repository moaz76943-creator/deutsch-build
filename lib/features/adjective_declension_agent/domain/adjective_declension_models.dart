enum DeclensionType { weak, strong, mixed }

enum GrammaticalCase { nominativ, akkusativ, dativ, genitiv }

enum GrammaticalGender { maskulin, feminin, neutral, plural }

final class AdjectiveExerciseItem {
  const AdjectiveExerciseItem({
    required this.id,
    required this.sentenceWithBlank,
    required this.baseAdjective,
    required this.correctEnding,
    required this.declensionType,
    required this.grammaticalCase,
    required this.grammaticalGender,
    required this.explanationAr,
  });

  final String id;
  final String sentenceWithBlank;
  final String baseAdjective;
  final String correctEnding;
  final DeclensionType declensionType;
  final GrammaticalCase grammaticalCase;
  final GrammaticalGender grammaticalGender;
  final String explanationAr;

  String get completedAdjective =>
      baseAdjective + correctEnding.substring(1);

  String renderCompletedSentence() =>
      sentenceWithBlank.replaceFirst('___', completedAdjective);
}
