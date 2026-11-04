// Sovereign Polyglot Core - Task 4496 (Supply Chain)
class Task4496Engine {
  static const int taskId = 4496;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitteilen';
  static const String praeteritum = 'teilte mit';
  static const String perfekt = 'hat mitgeteilt';
  static const String arabicTranslation = 'مشاركة / تنسيق التقسيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈtaɪ̯lən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4496_mitteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitteilen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التقسيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
