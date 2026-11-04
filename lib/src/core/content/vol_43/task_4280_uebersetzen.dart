// Sovereign Polyglot Core - Task 4280 (Supply Chain)
class Task4280Engine {
  static const int taskId = 4280;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'uebersetzen';
  static const String praeteritum = 'uebersetzte';
  static const String perfekt = 'hat uebersetzt';
  static const String arabicTranslation = 'مراجعة / نقل التنفيذ (سلاسل الإمداد)';
  static const String ipaTranscription = '[ueberˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4280_uebersetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale uebersetzen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التنفيذ في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
