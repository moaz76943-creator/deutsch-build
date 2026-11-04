// Sovereign Polyglot Core - Task 2196 (Software Architecture)
class Task2196Engine {
  static const int taskId = 2196;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitpruefen';
  static const String praeteritum = 'pruefte mit';
  static const String perfekt = 'hat mitgeprueft';
  static const String arabicTranslation = 'مشاركة / تنسيق التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈpʁyːfn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2196_mitpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitpruefen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
