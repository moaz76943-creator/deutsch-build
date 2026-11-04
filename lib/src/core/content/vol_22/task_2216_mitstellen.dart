// Sovereign Polyglot Core - Task 2216 (Software Architecture)
class Task2216Engine {
  static const int taskId = 2216;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitstellen';
  static const String praeteritum = 'stellte mit';
  static const String perfekt = 'hat mitgestellt';
  static const String arabicTranslation = 'مشاركة / تنسيق التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈʃtɛlən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2216_mitstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitstellen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
