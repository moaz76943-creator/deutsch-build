// Sovereign Polyglot Core - Task 3554 (Contractual Compliance)
class Task3554Engine {
  static const int taskId = 3554;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'ausschreiben';
  static const String praeteritum = 'schrieb aus';
  static const String perfekt = 'hat ausgeschrieben';
  static const String arabicTranslation = 'توسيع / استخراج التدوين (العقود والإدارة)';
  static const String ipaTranscription = '[ausˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3554_ausschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung ausschreiben.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التدوين أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
