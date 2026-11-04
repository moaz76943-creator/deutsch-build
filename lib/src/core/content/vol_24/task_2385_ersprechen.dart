// Sovereign Polyglot Core - Task 2385 (Software Architecture)
class Task2385Engine {
  static const int taskId = 2385;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ersprechen';
  static const String praeteritum = 'ersprach';
  static const String perfekt = 'hat ersprochen';
  static const String arabicTranslation = 'إنجاز / تحقيق التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[erˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2385_ersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ersprechen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
