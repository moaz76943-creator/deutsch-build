// Sovereign Polyglot Core - Task 2299 (Software Architecture)
class Task2299Engine {
  static const int taskId = 2299;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zunehmen';
  static const String praeteritum = 'nahm zu';
  static const String perfekt = 'hat zugenommen';
  static const String arabicTranslation = 'توجيه / إغلاق الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈneːmən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2299_zunehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zunehmen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
