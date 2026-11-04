// Sovereign Polyglot Core - Task 2451 (Software Architecture)
class Task2451Engine {
  static const int taskId = 2451;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abrechnen';
  static const String praeteritum = 'rechnete ab';
  static const String perfekt = 'hat abgerechnet';
  static const String arabicTranslation = 'فصل / إتمام التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2451_abrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abrechnen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
