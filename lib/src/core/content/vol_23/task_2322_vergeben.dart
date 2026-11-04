// Sovereign Polyglot Core - Task 2322 (Software Architecture)
class Task2322Engine {
  static const int taskId = 2322;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'vergeben';
  static const String praeteritum = 'vergab';
  static const String perfekt = 'hat vergeben';
  static const String arabicTranslation = 'توثيق / معالجة التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2322_vergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review vergeben.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
