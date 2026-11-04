// Sovereign Polyglot Core - Task 3305 (Academic Research)
class Task3305Engine {
  static const int taskId = 3305;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'erteilen';
  static const String praeteritum = 'erteilte';
  static const String perfekt = 'hat erteilt';
  static const String arabicTranslation = 'إنجاز / تحقيق التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[erˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3305_erteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt erteilen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
