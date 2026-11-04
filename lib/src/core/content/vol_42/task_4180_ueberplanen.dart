// Sovereign Polyglot Core - Task 4180 (Supply Chain)
class Task4180Engine {
  static const int taskId = 4180;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ueberplanen';
  static const String praeteritum = 'ueberplante';
  static const String perfekt = 'hat ueberplant';
  static const String arabicTranslation = 'مراجعة / نقل التخطيط (سلاسل الإمداد)';
  static const String ipaTranscription = '[ueberˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4180_ueberplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ueberplanen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخطيط في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
