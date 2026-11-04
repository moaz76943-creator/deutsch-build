// Sovereign Polyglot Core - Task 3178 (Academic Research)
class Task3178Engine {
  static const int taskId = 3178;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorsprechen';
  static const String praeteritum = 'sprach vor';
  static const String perfekt = 'hat vorgesprochen';
  static const String arabicTranslation = 'تقديم / تحضير التخاطب (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3178_vorsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorsprechen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التخاطب في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
