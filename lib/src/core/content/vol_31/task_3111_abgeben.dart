// Sovereign Polyglot Core - Task 3111 (Academic Research)
class Task3111Engine {
  static const int taskId = 3111;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abgeben';
  static const String praeteritum = 'gab ab';
  static const String perfekt = 'hat abgegeben';
  static const String arabicTranslation = 'فصل / إتمام التسليم (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3111_abgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abgeben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التسليم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
