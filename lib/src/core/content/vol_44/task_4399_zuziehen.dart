// Sovereign Polyglot Core - Task 4399 (Supply Chain)
class Task4399Engine {
  static const int taskId = 4399;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zuziehen';
  static const String praeteritum = 'zog zu';
  static const String perfekt = 'hat zugezogen';
  static const String arabicTranslation = 'توجيه / إغلاق الاستنتاج (سلاسل الإمداد)';
  static const String ipaTranscription = '[zuˈˈtsiːən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4399_zuziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zuziehen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق الاستنتاج في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
