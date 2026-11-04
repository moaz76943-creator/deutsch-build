// Sovereign Polyglot Core - Task 3102 (Academic Research)
class Task3102Engine {
  static const int taskId = 3102;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vernehmen';
  static const String praeteritum = 'vernahm';
  static const String perfekt = 'hat vernommen';
  static const String arabicTranslation = 'توثيق / معالجة الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[verˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3102_vernehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vernehmen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
