// Sovereign Polyglot Core - Task 3299 (Academic Research)
class Task3299Engine {
  static const int taskId = 3299;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zuteilen';
  static const String praeteritum = 'teilte zu';
  static const String perfekt = 'hat zugeteilt';
  static const String arabicTranslation = 'توجيه / إغلاق التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[zuˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3299_zuteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zuteilen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
