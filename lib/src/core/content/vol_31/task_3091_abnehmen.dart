// Sovereign Polyglot Core - Task 3091 (Academic Research)
class Task3091Engine {
  static const int taskId = 3091;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abnehmen';
  static const String praeteritum = 'nahm ab';
  static const String perfekt = 'hat abgenommen';
  static const String arabicTranslation = 'فصل / إتمام الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3091_abnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abnehmen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
