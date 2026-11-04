// Sovereign Polyglot Core - Task 4448 (Supply Chain)
class Task4448Engine {
  static const int taskId = 4448;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'weiterweisen';
  static const String praeteritum = 'wies weiter';
  static const String perfekt = 'hat weitergewiesen';
  static const String arabicTranslation = 'مواصلة / تمرير التوجيه (سلاسل الإمداد)';
  static const String ipaTranscription = '[weiterˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4448_weiterweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale weiterweisen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التوجيه في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
