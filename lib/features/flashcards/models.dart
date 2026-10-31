class FlashcardItem {
  final String id;
  final String text;
  final String translation;
  final String? example;
  final String? exampleTranslation;
  final bool hasAudio;
  final String sourceIso;
  final String targetIso;

  const FlashcardItem({
    required this.id,
    required this.text,
    required this.translation,
    this.example,
    this.exampleTranslation,
    this.hasAudio = false,
    required this.sourceIso,
    required this.targetIso,
  });
}
