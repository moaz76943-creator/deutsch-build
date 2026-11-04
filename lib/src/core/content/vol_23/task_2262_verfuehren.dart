// Sovereign Polyglot Core - Task 2262 (Software Architecture)
class Task2262Engine {
  static const int taskId = 2262;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'verfuehren';
  static const String praeteritum = 'verfuehrte';
  static const String perfekt = 'hat verfuehrt';
  static const String arabicTranslation = 'توثيق / معالجة الإدارة (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2262_verfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review verfuehren.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة الإدارة في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
