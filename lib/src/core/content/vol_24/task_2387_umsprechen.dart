// Sovereign Polyglot Core - Task 2387 (Software Architecture)
class Task2387Engine {
  static const int taskId = 2387;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umsprechen';
  static const String praeteritum = 'sprach um';
  static const String perfekt = 'hat umgesprochen';
  static const String arabicTranslation = 'إعادة هيكلة التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2387_umsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umsprechen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
