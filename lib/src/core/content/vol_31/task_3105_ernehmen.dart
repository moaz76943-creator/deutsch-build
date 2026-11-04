// Sovereign Polyglot Core - Task 3105 (Academic Research)
class Task3105Engine {
  static const int taskId = 3105;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ernehmen';
  static const String praeteritum = 'ernahm';
  static const String perfekt = 'hat ernommen';
  static const String arabicTranslation = 'إنجاز / تحقيق الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[erˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3105_ernehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ernehmen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
