// Sovereign Polyglot Core - Task 4157 (Supply Chain)
class Task4157Engine {
  static const int taskId = 4157;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'nacharbeiten';
  static const String praeteritum = 'arbeitete nach';
  static const String perfekt = 'hat nachgearbeitet';
  static const String arabicTranslation = 'تدقيق / متابعة العمل (سلاسل الإمداد)';
  static const String ipaTranscription = '[nachˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4157_nacharbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale nacharbeiten.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة العمل في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
