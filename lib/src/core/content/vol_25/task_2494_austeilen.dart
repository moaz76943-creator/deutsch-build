// Sovereign Polyglot Core - Task 2494 (Software Architecture)
class Task2494Engine {
  static const int taskId = 2494;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'austeilen';
  static const String praeteritum = 'teilte aus';
  static const String perfekt = 'hat ausgeteilt';
  static const String arabicTranslation = 'توسيع / استخراج التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[ausˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2494_austeilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review austeilen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
