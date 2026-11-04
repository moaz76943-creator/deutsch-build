// Sovereign Polyglot Core - Task 3634 (Contractual Compliance)
class Task3634Engine {
  static const int taskId = 3634;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ausweisen';
  static const String praeteritum = 'wies aus';
  static const String perfekt = 'hat ausgewiesen';
  static const String arabicTranslation = 'توسيع / استخراج التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3634_ausweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ausweisen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
