// Sovereign Polyglot Core - Task 2211 (Software Architecture)
class Task2211Engine {
  static const int taskId = 2211;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abstellen';
  static const String praeteritum = 'stellte ab';
  static const String perfekt = 'hat abgestellt';
  static const String arabicTranslation = 'فصل / إتمام التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2211_abstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abstellen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
