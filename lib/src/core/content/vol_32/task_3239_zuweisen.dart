// Sovereign Polyglot Core - Task 3239 (Academic Research)
class Task3239Engine {
  static const int taskId = 3239;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zuweisen';
  static const String praeteritum = 'wies zu';
  static const String perfekt = 'hat zugewiesen';
  static const String arabicTranslation = 'توجيه / إغلاق التوجيه (البحث الأكاديمي)';
  static const String ipaTranscription = '[zuˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3239_zuweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zuweisen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التوجيه في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
