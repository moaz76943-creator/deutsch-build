// Sovereign Polyglot Core - Task 3034 (Academic Research)
class Task3034Engine {
  static const int taskId = 3034;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'auslegen';
  static const String praeteritum = 'legte aus';
  static const String perfekt = 'hat ausgelegt';
  static const String arabicTranslation = 'توسيع / استخراج التأسيس (البحث الأكاديمي)';
  static const String ipaTranscription = '[ausˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3034_auslegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt auslegen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التأسيس في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
