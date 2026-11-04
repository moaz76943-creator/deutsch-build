// Sovereign Polyglot Core - Task 3230 (Academic Research)
class Task3230Engine {
  static const int taskId = 3230;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'festtragen';
  static const String praeteritum = 'trug fest';
  static const String perfekt = 'hat festgetragen';
  static const String arabicTranslation = 'تثبيت / إقرار المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[festˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3230_festtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt festtragen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
