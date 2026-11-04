// Sovereign Polyglot Core - Task 2493 (Software Architecture)
class Task2493Engine {
  static const int taskId = 2493;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufteilen';
  static const String praeteritum = 'teilte auf';
  static const String perfekt = 'hat aufgeteilt';
  static const String arabicTranslation = 'رفع / فتح التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2493_aufteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufteilen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
