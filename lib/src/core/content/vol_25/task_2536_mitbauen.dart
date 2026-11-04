// Sovereign Polyglot Core - Task 2536 (Software Architecture)
class Task2536Engine {
  static const int taskId = 2536;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitbauen';
  static const String praeteritum = 'baute mit';
  static const String perfekt = 'hat mitgebaut';
  static const String arabicTranslation = 'مشاركة / تنسيق التطوير (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈbaʊ̯ən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2536_mitbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitbauen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التطوير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
