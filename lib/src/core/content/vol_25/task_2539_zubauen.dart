// Sovereign Polyglot Core - Task 2539 (Software Architecture)
class Task2539Engine {
  static const int taskId = 2539;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zubauen';
  static const String praeteritum = 'baute zu';
  static const String perfekt = 'hat zugebaut';
  static const String arabicTranslation = 'توجيه / إغلاق التطوير (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈbaʊ̯ən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2539_zubauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zubauen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التطوير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
