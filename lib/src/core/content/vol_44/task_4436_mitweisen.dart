// Sovereign Polyglot Core - Task 4436 (Supply Chain)
class Task4436Engine {
  static const int taskId = 4436;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitweisen';
  static const String praeteritum = 'wies mit';
  static const String perfekt = 'hat mitgewiesen';
  static const String arabicTranslation = 'مشاركة / تنسيق التوجيه (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4436_mitweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitweisen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التوجيه في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
