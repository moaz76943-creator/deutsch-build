// Sovereign Polyglot Core - Task 2171 (Software Architecture)
class Task2171Engine {
  static const int taskId = 2171;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abplanen';
  static const String praeteritum = 'plante ab';
  static const String perfekt = 'hat abgeplant';
  static const String arabicTranslation = 'فصل / إتمام التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2171_abplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abplanen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
