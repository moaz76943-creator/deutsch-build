// Sovereign Polyglot Core - Task 4478 (Supply Chain)
class Task4478Engine {
  static const int taskId = 4478;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'vorordnen';
  static const String praeteritum = 'ordnete vor';
  static const String perfekt = 'hat vorgeordnet';
  static const String arabicTranslation = 'تقديم / تحضير التصنيف (سلاسل الإمداد)';
  static const String ipaTranscription = '[vorˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4478_vorordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale vorordnen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التصنيف في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
