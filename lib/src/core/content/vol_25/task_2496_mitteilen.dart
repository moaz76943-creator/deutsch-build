// Sovereign Polyglot Core - Task 2496 (Software Architecture)
class Task2496Engine {
  static const int taskId = 2496;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitteilen';
  static const String praeteritum = 'teilte mit';
  static const String perfekt = 'hat mitgeteilt';
  static const String arabicTranslation = 'مشاركة / تنسيق التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2496_mitteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitteilen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
