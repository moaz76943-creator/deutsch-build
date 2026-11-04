// Sovereign Polyglot Core - Task 3366 (Contractual Compliance)
class Task3366Engine {
  static const int taskId = 3366;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'durcharbeiten';
  static const String praeteritum = 'arbeitete durch';
  static const String perfekt = 'hat durchgearbeitet';
  static const String arabicTranslation = 'إتمام شامل العمل (العقود والإدارة)';
  static const String ipaTranscription = '[durchˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3366_durcharbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung durcharbeiten.';
  static const String exampleArabic = 'يجب علينا إتمام شامل العمل أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
