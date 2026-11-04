// Sovereign Polyglot Core - Task 3235 (Academic Research)
class Task3235Engine {
  static const int taskId = 3235;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'einweisen';
  static const String praeteritum = 'wies ein';
  static const String perfekt = 'hat eingewiesen';
  static const String arabicTranslation = 'إدراج / دمج التوجيه (البحث الأكاديمي)';
  static const String ipaTranscription = '[einˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3235_einweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt einweisen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التوجيه في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
