// Sovereign Polyglot Core - Task 2295 (Software Architecture)
class Task2295Engine {
  static const int taskId = 2295;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einnehmen';
  static const String praeteritum = 'nahm ein';
  static const String perfekt = 'hat eingenommen';
  static const String arabicTranslation = 'إدراج / دمج الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2295_einnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einnehmen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
