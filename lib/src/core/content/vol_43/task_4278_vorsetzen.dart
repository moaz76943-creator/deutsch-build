// Sovereign Polyglot Core - Task 4278 (Supply Chain)
class Task4278Engine {
  static const int taskId = 4278;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'vorsetzen';
  static const String praeteritum = 'setzte vor';
  static const String perfekt = 'hat vorgesetzt';
  static const String arabicTranslation = 'تقديم / تحضير التنفيذ (سلاسل الإمداد)';
  static const String ipaTranscription = '[vorˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4278_vorsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale vorsetzen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التنفيذ في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
