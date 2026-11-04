// Sovereign Polyglot Core - Task 4493 (Supply Chain)
class Task4493Engine {
  static const int taskId = 4493;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'aufteilen';
  static const String praeteritum = 'teilte auf';
  static const String perfekt = 'hat aufgeteilt';
  static const String arabicTranslation = 'رفع / فتح التقسيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[aufˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4493_aufteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale aufteilen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التقسيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
