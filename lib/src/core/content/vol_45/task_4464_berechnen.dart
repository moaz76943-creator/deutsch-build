// Sovereign Polyglot Core - Task 4464 (Supply Chain)
class Task4464Engine {
  static const int taskId = 4464;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'berechnen';
  static const String praeteritum = 'berechnete';
  static const String perfekt = 'hat berechnet';
  static const String arabicTranslation = 'تأكيد / تزويد التقدير (سلاسل الإمداد)';
  static const String ipaTranscription = '[beˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4464_berechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale berechnen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التقدير في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
