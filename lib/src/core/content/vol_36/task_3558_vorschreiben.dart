// Sovereign Polyglot Core - Task 3558 (Contractual Compliance)
class Task3558Engine {
  static const int taskId = 3558;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'vorschreiben';
  static const String praeteritum = 'schrieb vor';
  static const String perfekt = 'hat vorgeschrieben';
  static const String arabicTranslation = 'تقديم / تحضير التدوين (العقود والإدارة)';
  static const String ipaTranscription = '[vorˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3558_vorschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung vorschreiben.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التدوين أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
