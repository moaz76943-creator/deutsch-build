// Sovereign Polyglot Core - Task 2251 (Software Architecture)
class Task2251Engine {
  static const int taskId = 2251;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abfuehren';
  static const String praeteritum = 'fuehrte ab';
  static const String perfekt = 'hat abgefuehrt';
  static const String arabicTranslation = 'فصل / إتمام الإدارة (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2251_abfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abfuehren.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الإدارة في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
