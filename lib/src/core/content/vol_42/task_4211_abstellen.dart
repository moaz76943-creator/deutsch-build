// Sovereign Polyglot Core - Task 4211 (Supply Chain)
class Task4211Engine {
  static const int taskId = 4211;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'abstellen';
  static const String praeteritum = 'stellte ab';
  static const String perfekt = 'hat abgestellt';
  static const String arabicTranslation = 'فصل / إتمام التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4211_abstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale abstellen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
