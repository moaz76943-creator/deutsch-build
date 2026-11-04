// Sovereign Polyglot Core - Task 2296 (Software Architecture)
class Task2296Engine {
  static const int taskId = 2296;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitnehmen';
  static const String praeteritum = 'nahm mit';
  static const String perfekt = 'hat mitgenommen';
  static const String arabicTranslation = 'مشاركة / تنسيق الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈneːmən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2296_mitnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitnehmen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
