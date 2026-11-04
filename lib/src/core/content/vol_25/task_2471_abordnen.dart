// Sovereign Polyglot Core - Task 2471 (Software Architecture)
class Task2471Engine {
  static const int taskId = 2471;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abordnen';
  static const String praeteritum = 'ordnete ab';
  static const String perfekt = 'hat abgeordnet';
  static const String arabicTranslation = 'فصل / إتمام التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2471_abordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abordnen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
