// Sovereign Polyglot Core - Task 2390 (Software Architecture)
class Task2390Engine {
  static const int taskId = 2390;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'festsprechen';
  static const String praeteritum = 'sprach fest';
  static const String perfekt = 'hat festgesprochen';
  static const String arabicTranslation = 'تثبيت / إقرار التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[festˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2390_festsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review festsprechen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
