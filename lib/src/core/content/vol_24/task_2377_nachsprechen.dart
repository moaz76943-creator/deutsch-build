// Sovereign Polyglot Core - Task 2377 (Software Architecture)
class Task2377Engine {
  static const int taskId = 2377;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'nachsprechen';
  static const String praeteritum = 'sprach nach';
  static const String perfekt = 'hat nachgesprochen';
  static const String arabicTranslation = 'تدقيق / متابعة التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[nachˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2377_nachsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review nachsprechen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
