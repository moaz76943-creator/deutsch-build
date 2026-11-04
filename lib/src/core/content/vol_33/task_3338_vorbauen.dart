// Sovereign Polyglot Core - Task 3338 (Academic Research)
class Task3338Engine {
  static const int taskId = 3338;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorbauen';
  static const String praeteritum = 'baute vor';
  static const String perfekt = 'hat vorgebaut';
  static const String arabicTranslation = 'تقديم / تحضير التطوير (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3338_vorbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorbauen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التطوير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
