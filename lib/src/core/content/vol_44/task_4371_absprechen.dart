// Sovereign Polyglot Core - Task 4371 (Supply Chain)
class Task4371Engine {
  static const int taskId = 4371;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'absprechen';
  static const String praeteritum = 'sprach ab';
  static const String perfekt = 'hat abgesprochen';
  static const String arabicTranslation = 'فصل / إتمام التخاطب (سلاسل الإمداد)';
  static const String ipaTranscription = '[abˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4371_absprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale absprechen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التخاطب في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
