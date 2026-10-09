class MorphemeBlock {
  final String text;
  final bool isRoot;
  final String type;

  const MorphemeBlock({
    required this.text,
    required this.isRoot,
    required this.type,
  });
}

class AmbiguityTask {
  final List<String> sentenceTokens;
  final List<int> blurredIndices;
  final String question;
  final String correctAnswer;
  final String hint;

  const AmbiguityTask({
    required this.sentenceTokens,
    required this.blurredIndices,
    required this.question,
    required this.correctAnswer,
    required this.hint,
  });
}

class MetaphorConcept {
  final String coreConcept;
  final String sourceLanguageMetaphor;
  final String targetLanguageMetaphor;
  final String explanation;

  const MetaphorConcept({
    required this.coreConcept,
    required this.sourceLanguageMetaphor,
    required this.targetLanguageMetaphor,
    required this.explanation,
  });
}
