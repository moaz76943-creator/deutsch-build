// Sovereign Polyglot Core - Task 2462 (Software Architecture)
class Task2462Engine {
  static const int taskId = 2462;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'verrechnen';
  static const String praeteritum = 'verrechnete';
  static const String perfekt = 'hat verrechnet';
  static const String arabicTranslation = 'توثيق / معالجة التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2462_verrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review verrechnen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
