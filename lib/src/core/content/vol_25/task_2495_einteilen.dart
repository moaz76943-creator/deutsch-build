// Sovereign Polyglot Core - Task 2495 (Software Architecture)
class Task2495Engine {
  static const int taskId = 2495;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einteilen';
  static const String praeteritum = 'teilte ein';
  static const String perfekt = 'hat eingeteilt';
  static const String arabicTranslation = 'إدراج / دمج التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2495_einteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einteilen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
