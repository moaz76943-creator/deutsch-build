class FlashcardData {
  final String id;
  final String frontText;
  final String backText;
  final String? example;
  final String? translation;
  final bool hasAudio;
  final String sourceIso;
  final String targetIso;
  final int currentIntervalDays;
  final double currentEaseFactor;
  final int currentRepetitions;

  const FlashcardData({
    required this.id,
    required this.frontText,
    required this.backText,
    this.example,
    this.translation,
    this.hasAudio = false,
    required this.sourceIso,
    required this.targetIso,
    this.currentIntervalDays = 0,
    this.currentEaseFactor = 2.5,
    this.currentRepetitions = 0,
  });
}
