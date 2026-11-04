// Sovereign Polyglot Core - Task 3074 (Academic Research)
class Task3074Engine {
  static const int taskId = 3074;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aussetzen';
  static const String praeteritum = 'setzte aus';
  static const String perfekt = 'hat ausgesetzt';
  static const String arabicTranslation = 'توسيع / استخراج التنفيذ (البحث الأكاديمي)';
  static const String ipaTranscription = '[ausˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3074_aussetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aussetzen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التنفيذ في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
