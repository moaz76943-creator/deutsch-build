// Sovereign Polyglot Core - Task 4169 (Supply Chain)
class Task4169Engine {
  static const int taskId = 4169;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'zusammenarbeiten';
  static const String praeteritum = 'arbeitete zusammen';
  static const String perfekt = 'hat zusammengearbeitet';
  static const String arabicTranslation = 'تجميع / توحيد العمل (سلاسل الإمداد)';
  static const String ipaTranscription = '[zusammenˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4169_zusammenarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale zusammenarbeiten.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد العمل في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
