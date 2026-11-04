// Sovereign Polyglot Core - Task 3039 (Academic Research)
class Task3039Engine {
  static const int taskId = 3039;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zulegen';
  static const String praeteritum = 'legte zu';
  static const String perfekt = 'hat zugelegt';
  static const String arabicTranslation = 'توجيه / إغلاق التأسيس (البحث الأكاديمي)';
  static const String ipaTranscription = '[zuˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3039_zulegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zulegen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التأسيس في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
