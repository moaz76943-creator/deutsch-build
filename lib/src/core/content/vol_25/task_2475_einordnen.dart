// Sovereign Polyglot Core - Task 2475 (Software Architecture)
class Task2475Engine {
  static const int taskId = 2475;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einordnen';
  static const String praeteritum = 'ordnete ein';
  static const String perfekt = 'hat eingeordnet';
  static const String arabicTranslation = 'إدراج / دمج التصنيف (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2475_einordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einordnen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التصنيف في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
