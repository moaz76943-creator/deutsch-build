// Sovereign Polyglot Core - Task 2371 (Software Architecture)
class Task2371Engine {
  static const int taskId = 2371;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'absprechen';
  static const String praeteritum = 'sprach ab';
  static const String perfekt = 'hat abgesprochen';
  static const String arabicTranslation = 'فصل / إتمام التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2371_absprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review absprechen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
