// Sovereign Polyglot Core - Task 3110 (Academic Research)
class Task3110Engine {
  static const int taskId = 3110;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'festnehmen';
  static const String praeteritum = 'nahm fest';
  static const String perfekt = 'hat festgenommen';
  static const String arabicTranslation = 'تثبيت / إقرار الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[festˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3110_festnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt festnehmen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
