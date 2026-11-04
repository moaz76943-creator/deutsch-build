// Sovereign Polyglot Core - Task 2324 (Software Architecture)
class Task2324Engine {
  static const int taskId = 2324;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'begeben';
  static const String praeteritum = 'begab';
  static const String perfekt = 'hat begeben';
  static const String arabicTranslation = 'تأكيد / تزويد التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[beˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2324_begeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review begeben.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
