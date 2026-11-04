// Sovereign Polyglot Core - Task 4213 (Supply Chain)
class Task4213Engine {
  static const int taskId = 4213;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'aufstellen';
  static const String praeteritum = 'stellte auf';
  static const String perfekt = 'hat aufgestellt';
  static const String arabicTranslation = 'رفع / فتح التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[aufˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4213_aufstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale aufstellen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
