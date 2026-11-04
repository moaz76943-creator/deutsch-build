// Sovereign Polyglot Core - Task 4409 (Supply Chain)
class Task4409Engine {
  static const int taskId = 4409;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zusammenziehen';
  static const String praeteritum = 'zog zusammen';
  static const String perfekt = 'hat zusammengezogen';
  static const String arabicTranslation = 'تجميع / توحيد الاستنتاج (سلاسل الإمداد)';
  static const String ipaTranscription = '[zusammenˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4409_zusammenziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zusammenziehen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الاستنتاج في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
