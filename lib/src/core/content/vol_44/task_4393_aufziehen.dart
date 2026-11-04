// Sovereign Polyglot Core - Task 4393 (Supply Chain)
class Task4393Engine {
  static const int taskId = 4393;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'aufziehen';
  static const String praeteritum = 'zog auf';
  static const String perfekt = 'hat aufgezogen';
  static const String arabicTranslation = 'رفع / فتح الاستنتاج (سلاسل الإمداد)';
  static const String ipaTranscription = '[aufˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4393_aufziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale aufziehen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الاستنتاج في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
