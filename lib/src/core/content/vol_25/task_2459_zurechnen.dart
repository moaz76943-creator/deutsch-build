// Sovereign Polyglot Core - Task 2459 (Software Architecture)
class Task2459Engine {
  static const int taskId = 2459;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zurechnen';
  static const String praeteritum = 'rechnete zu';
  static const String perfekt = 'hat zugerechnet';
  static const String arabicTranslation = 'توجيه / إغلاق التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈʁɛçnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2459_zurechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zurechnen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
