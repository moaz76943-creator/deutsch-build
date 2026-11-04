// Sovereign Polyglot Core - Task 2419 (Software Architecture)
class Task2419Engine {
  static const int taskId = 2419;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zutragen';
  static const String praeteritum = 'trug zu';
  static const String perfekt = 'hat zugetragen';
  static const String arabicTranslation = 'توجيه / إغلاق المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2419_zutragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zutragen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
