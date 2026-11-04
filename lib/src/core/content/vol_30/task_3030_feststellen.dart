// Sovereign Polyglot Core - Task 3030 (Academic Research)
class Task3030Engine {
  static const int taskId = 3030;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'feststellen';
  static const String praeteritum = 'stellte fest';
  static const String perfekt = 'hat festgestellt';
  static const String arabicTranslation = 'تثبيت / إقرار التنظيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[festˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3030_feststellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt feststellen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التنظيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
