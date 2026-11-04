// Sovereign Polyglot Core - Task 2550 (Software Architecture)
class Task2550Engine {
  static const int taskId = 2550;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'festbauen';
  static const String praeteritum = 'baute fest';
  static const String perfekt = 'hat festgebaut';
  static const String arabicTranslation = 'تثبيت / إقرار التطوير (هندسة البرمجيات)';
  static const String ipaTranscription = '[festˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2550_festbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review festbauen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التطوير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
