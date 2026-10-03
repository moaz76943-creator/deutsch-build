enum AudioVariant { word, sentence, pronunciation }

final class AudioRequest {
  const AudioRequest({
    required this.text,
    required this.languageCode,
    this.conceptId,
    this.variant = AudioVariant.word,
    this.rate,
  });

  final String text;
  final String languageCode;
  final String? conceptId;
  final AudioVariant variant;
  final double? rate;

  bool get hasText => text.trim().isNotEmpty;
}
