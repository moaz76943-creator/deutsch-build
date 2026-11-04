// Sovereign Polyglot Core - Task 3171 (Academic Research)
class Task3171Engine {
  static const int taskId = 3171;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'absprechen';
  static const String praeteritum = 'sprach ab';
  static const String perfekt = 'hat abgesprochen';
  static const String arabicTranslation = 'فصل / إتمام التخاطب (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3171_absprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt absprechen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التخاطب في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
