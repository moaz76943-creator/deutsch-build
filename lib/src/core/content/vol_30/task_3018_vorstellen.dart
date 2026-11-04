// Sovereign Polyglot Core - Task 3018 (Academic Research)
class Task3018Engine {
  static const int taskId = 3018;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorstellen';
  static const String praeteritum = 'stellte vor';
  static const String perfekt = 'hat vorgestellt';
  static const String arabicTranslation = 'تقديم / تحضير التنظيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3018_vorstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorstellen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التنظيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
