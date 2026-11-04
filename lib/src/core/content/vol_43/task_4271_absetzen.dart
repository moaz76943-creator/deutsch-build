// Sovereign Polyglot Core - Task 4271 (Supply Chain)
class Task4271Engine {
  static const int taskId = 4271;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'absetzen';
  static const String praeteritum = 'setzte ab';
  static const String perfekt = 'hat abgesetzt';
  static const String arabicTranslation = 'فصل / إتمام التنفيذ (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4271_absetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale absetzen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنفيذ في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
