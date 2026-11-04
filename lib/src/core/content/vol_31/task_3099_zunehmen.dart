// Sovereign Polyglot Core - Task 3099 (Academic Research)
class Task3099Engine {
  static const int taskId = 3099;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zunehmen';
  static const String praeteritum = 'nahm zu';
  static const String perfekt = 'hat zugenommen';
  static const String arabicTranslation = 'توجيه / إغلاق الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[zuˈˈneːmən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3099_zunehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zunehmen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
