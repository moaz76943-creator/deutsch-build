// Sovereign Polyglot Core - Task 2312 (Software Architecture)
class Task2312Engine {
  static const int taskId = 2312;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'angeben';
  static const String praeteritum = 'gab an';
  static const String perfekt = 'hat angegeben';
  static const String arabicTranslation = 'بدء / توجيه التسليم (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2312_angeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review angeben.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التسليم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
