// Sovereign Polyglot Core - Task 2379 (Software Architecture)
class Task2379Engine {
  static const int taskId = 2379;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusprechen';
  static const String praeteritum = 'sprach zu';
  static const String perfekt = 'hat zugesprochen';
  static const String arabicTranslation = 'توجيه / إغلاق التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2379_zusprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusprechen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
