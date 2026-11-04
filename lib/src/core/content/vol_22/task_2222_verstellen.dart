// Sovereign Polyglot Core - Task 2222 (Software Architecture)
class Task2222Engine {
  static const int taskId = 2222;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'verstellen';
  static const String praeteritum = 'verstellte';
  static const String perfekt = 'hat verstellt';
  static const String arabicTranslation = 'توثيق / معالجة التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2222_verstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review verstellen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
