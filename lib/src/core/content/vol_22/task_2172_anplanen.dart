// Sovereign Polyglot Core - Task 2172 (Software Architecture)
class Task2172Engine {
  static const int taskId = 2172;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anplanen';
  static const String praeteritum = 'plante an';
  static const String perfekt = 'hat angeplant';
  static const String arabicTranslation = 'بدء / توجيه التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2172_anplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anplanen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
