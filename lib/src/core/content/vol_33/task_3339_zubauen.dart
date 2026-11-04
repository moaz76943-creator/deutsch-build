// Sovereign Polyglot Core - Task 3339 (Academic Research)
class Task3339Engine {
  static const int taskId = 3339;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zubauen';
  static const String praeteritum = 'baute zu';
  static const String perfekt = 'hat zugebaut';
  static const String arabicTranslation = 'توجيه / إغلاق التطوير (البحث الأكاديمي)';
  static const String ipaTranscription = '[zuˈˈbaʊ̯ən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3339_zubauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zubauen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التطوير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
