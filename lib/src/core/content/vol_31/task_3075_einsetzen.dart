// Sovereign Polyglot Core - Task 3075 (Academic Research)
class Task3075Engine {
  static const int taskId = 3075;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'einsetzen';
  static const String praeteritum = 'setzte ein';
  static const String perfekt = 'hat eingesetzt';
  static const String arabicTranslation = 'إدراج / دمج التنفيذ (البحث الأكاديمي)';
  static const String ipaTranscription = '[einˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3075_einsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt einsetzen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التنفيذ في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
