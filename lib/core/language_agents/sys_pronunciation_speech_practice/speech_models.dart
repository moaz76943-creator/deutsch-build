final class SpeechPracticePrompt {
  const SpeechPracticePrompt({
    required this.id,
    required this.text,
    required this.languageCode,
    required this.localeId,
    required this.conceptId,
    this.acceptedForms = const <String>[],
  });

  final String id;
  final String text;
  final String languageCode;
  final String localeId;
  final String conceptId;
  final List<String> acceptedForms;

  bool get isValid =>
      id.trim().isNotEmpty &&
      text.trim().isNotEmpty &&
      languageCode.trim().isNotEmpty &&
      localeId.trim().isNotEmpty &&
      conceptId.trim().isNotEmpty;
}

final class SpeechComparison {
  const SpeechComparison({
    required this.recognizedText,
    required this.matchedTarget,
    required this.similarity,
    required this.isExact,
    required this.isAccepted,
    required this.feedbackCode,
  });

  final String recognizedText;
  final String matchedTarget;
  final double similarity;
  final bool isExact;
  final bool isAccepted;
  final String feedbackCode;
}

final class SpeechRecognitionSnapshot {
  const SpeechRecognitionSnapshot({
    required this.text,
    required this.isFinal,
    required this.evaluation,
  });

  final String text;
  final bool isFinal;
  final SpeechComparison evaluation;
}
