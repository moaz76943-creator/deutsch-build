// Sovereign Polyglot Core - Task 3090 (Academic Research)
class Task3090Engine {
  static const int taskId = 3090;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'festsetzen';
  static const String praeteritum = 'setzte fest';
  static const String perfekt = 'hat festgesetzt';
  static const String arabicTranslation = 'تثبيت / إقرار التنفيذ (البحث الأكاديمي)';
  static const String ipaTranscription = '[festˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3090_festsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt festsetzen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التنفيذ في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
