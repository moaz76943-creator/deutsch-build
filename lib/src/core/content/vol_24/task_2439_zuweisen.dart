// Sovereign Polyglot Core - Task 2439 (Software Architecture)
class Task2439Engine {
  static const int taskId = 2439;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zuweisen';
  static const String praeteritum = 'wies zu';
  static const String perfekt = 'hat zugewiesen';
  static const String arabicTranslation = 'توجيه / إغلاق التوجيه (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2439_zuweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zuweisen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التوجيه في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
