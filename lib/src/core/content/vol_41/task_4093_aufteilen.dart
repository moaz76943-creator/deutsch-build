// Sovereign Polyglot Core - Task 4093 (Financial Auditing)
class Task4093Engine {
  static const int taskId = 4093;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'aufteilen';
  static const String praeteritum = 'teilte auf';
  static const String perfekt = 'hat aufgeteilt';
  static const String arabicTranslation = 'رفع / فتح التقسيم (التدقيق المالي)';
  static const String ipaTranscription = '[aufˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4093_aufteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung aufteilen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التقسيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
