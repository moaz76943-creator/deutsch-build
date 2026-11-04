// Sovereign Polyglot Core - Task 4154 (Supply Chain)
class Task4154Engine {
  static const int taskId = 4154;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'ausarbeiten';
  static const String praeteritum = 'arbeitete aus';
  static const String perfekt = 'hat ausgearbeitet';
  static const String arabicTranslation = 'توسيع / استخراج العمل (سلاسل الإمداد)';
  static const String ipaTranscription = '[ausˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4154_ausarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale ausarbeiten.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج العمل في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
