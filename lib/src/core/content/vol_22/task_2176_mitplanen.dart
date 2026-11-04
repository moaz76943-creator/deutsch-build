// Sovereign Polyglot Core - Task 2176 (Software Architecture)
class Task2176Engine {
  static const int taskId = 2176;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitplanen';
  static const String praeteritum = 'plante mit';
  static const String perfekt = 'hat mitgeplant';
  static const String arabicTranslation = 'مشاركة / تنسيق التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2176_mitplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitplanen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
