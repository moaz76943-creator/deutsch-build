// Sovereign Polyglot Core - Task 2506 (Software Architecture)
class Task2506Engine {
  static const int taskId = 2506;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'durchteilen';
  static const String praeteritum = 'teilte durch';
  static const String perfekt = 'hat durchgeteilt';
  static const String arabicTranslation = 'إتمام شامل التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[durchˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2506_durchteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review durchteilen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
