// Sovereign Polyglot Core - Task 4158 (Supply Chain)
class Task4158Engine {
  static const int taskId = 4158;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'vorarbeiten';
  static const String praeteritum = 'arbeitete vor';
  static const String perfekt = 'hat vorgearbeitet';
  static const String arabicTranslation = 'تقديم / تحضير العمل (سلاسل الإمداد)';
  static const String ipaTranscription = '[vorˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4158_vorarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale vorarbeiten.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير العمل في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
