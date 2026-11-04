// Sovereign Polyglot Core - Task 3632 (Contractual Compliance)
class Task3632Engine {
  static const int taskId = 3632;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'anweisen';
  static const String praeteritum = 'wies an';
  static const String perfekt = 'hat angewiesen';
  static const String arabicTranslation = 'بدء / توجيه التوجيه (العقود والإدارة)';
  static const String ipaTranscription = '[anˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3632_anweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung anweisen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التوجيه أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
