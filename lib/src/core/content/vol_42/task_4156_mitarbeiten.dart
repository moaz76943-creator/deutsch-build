// Sovereign Polyglot Core - Task 4156 (Supply Chain)
class Task4156Engine {
  static const int taskId = 4156;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitarbeiten';
  static const String praeteritum = 'arbeitete mit';
  static const String perfekt = 'hat mitgearbeitet';
  static const String arabicTranslation = 'مشاركة / تنسيق العمل (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4156_mitarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitarbeiten.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق العمل في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
