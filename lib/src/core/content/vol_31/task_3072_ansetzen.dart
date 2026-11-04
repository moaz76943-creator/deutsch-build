// Sovereign Polyglot Core - Task 3072 (Academic Research)
class Task3072Engine {
  static const int taskId = 3072;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ansetzen';
  static const String praeteritum = 'setzte an';
  static const String perfekt = 'hat angesetzt';
  static const String arabicTranslation = 'بدء / توجيه التنفيذ (البحث الأكاديمي)';
  static const String ipaTranscription = '[anˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3072_ansetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ansetzen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التنفيذ في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
