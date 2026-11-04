// Sovereign Polyglot Core - Task 3071 (Academic Research)
class Task3071Engine {
  static const int taskId = 3071;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'absetzen';
  static const String praeteritum = 'setzte ab';
  static const String perfekt = 'hat abgesetzt';
  static const String arabicTranslation = 'فصل / إتمام التنفيذ (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3071_absetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt absetzen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنفيذ في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
