// Sovereign Polyglot Core - Task 2382 (Software Architecture)
class Task2382Engine {
  static const int taskId = 2382;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'versprechen';
  static const String praeteritum = 'versprach';
  static const String perfekt = 'hat versprochen';
  static const String arabicTranslation = 'توثيق / معالجة التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2382_versprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review versprechen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
